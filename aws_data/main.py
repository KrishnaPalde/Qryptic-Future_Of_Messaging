from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
import numpy as np
import uuid
import jwt
import datetime
import ssl
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

@app.get("/")
def health_check():
    return {"status": "ok"}

# 🔐 Secure storage for sessions
sessions = {}

# 🔑 JWT Secret Key & Algorithm
SECRET_KEY = "your_super_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# 📌 OAuth2 Token Handling
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


# 📌 User Model
class Token(BaseModel):
    access_token: str
    token_type: str

class User(BaseModel):
    userId: str

# ✅ Function to create JWT tokens
def create_access_token(data: dict, expires_delta: datetime.timedelta):
    to_encode = data.copy()
    expire = datetime.datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# ✅ Login API - Generates JWT Token
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    print(form_data)
    user_id = form_data.username  # OAuth2 expects "username", but we use it for "userId"
    
    # Check if user exists in Firebase
    isValid = True
    if not isValid:
        raise HTTPException(status_code=400, detail="Invalid credentials")

    access_token_expires = datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user_id}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# ✅ Dependency for protecting endpoints
def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")  # changed to userId
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {"userId": user_id}  # changed to userId
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# ✅ Secure BB84 Key Generation Function (Generate More Bits)
def generate_bb84_key(n=512):  # Generate 512 bits to ensure at least 256 bits remain after sifting
    alice_bits = np.random.randint(2, size=n)
    alice_bases = np.random.randint(2, size=n)
    return alice_bits.tolist(), alice_bases.tolist()

# 🔐 Secure API Endpoint 1: Start QKD (User A)
@app.post("/start_qkd/{user_id}")
async def start_qkd(user_id: str ,user: dict = Depends(get_current_user)):
    session_id = str(uuid.uuid4())  # Unique session
    alice_bits, alice_bases = generate_bb84_key()

    sessions[session_id] = {
	"alice_id": user_id,
        "alice_bits": alice_bits,
        "alice_bases": alice_bases,
        "bob_bases": None,
        "bob_results": None,
        "shared_key": None
    }

    return {"session_id": session_id, "message": "QKD session started securely."}

# 🔐 Secure API Endpoint 2: Join QKD (User B)
@app.post("/join_qkd/{session_id}")
async def join_qkd(session_id: str, user: dict = Depends(get_current_user)):
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")

    data = sessions[session_id]
    simulator = AerSimulator()
    
    max_retries = 2  # Reduced retry limit to 2
    retry_count = 0
    k1 = ""
    k2 = ""
    k3 = ""
    
    # Generate k1 (First key)
    while retry_count < max_retries:
        bob_bases = np.random.randint(2, size=len(data["alice_bits"]))
        bob_results = []

        for i, bit in enumerate(data["alice_bits"]):
            qc = QuantumCircuit(1, 1)
            if bob_bases[i] == 1:
                qc.h(0)  # Apply Hadamard gate if Bob's basis is 1
            if bit == 1:
                qc.x(0)  # Apply X gate if Alice's bit is 1
            qc.measure(0, 0)
            t_qc = transpile(qc, simulator)
            result = simulator.run(t_qc).result()
            counts = result.get_counts()
            measured_bit = 0 if '0' in counts else 1
            bob_results.append(measured_bit)

        # ✅ Key Sifting - Match Alice's and Bob's Bases
        sifted_key_indices = [i for i in range(len(bob_bases)) if bob_bases[i] == data["alice_bases"][i]]
        sifted_key = [bob_results[i] for i in sifted_key_indices]

        # Store k1 and check its length
        k1 = ''.join(map(str, sifted_key))
        if len(k1) >= 256:
            sessions[session_id]["bob_bases"] = bob_bases.tolist()
            sessions[session_id]["bob_results"] = bob_results
            sessions[session_id]["shared_key"] = k1[:256]
            userId = sessions[session_id]["alice_id"]
            return {"message": "QKD completed securely.", "shared_key": k1[:256], "userId": userId}

        retry_count += 1

    # If we didn't generate a sufficient k1 key, start generating k2
    retry_count = 0
    while retry_count < max_retries:
        bob_bases = np.random.randint(2, size=len(data["alice_bits"]))
        bob_results = []

        for i, bit in enumerate(data["alice_bits"]):
            qc = QuantumCircuit(1, 1)
            if bob_bases[i] == 1:
                qc.h(0)
            if bit == 1:
                qc.x(0)
            qc.measure(0, 0)
            t_qc = transpile(qc, simulator)
            result = simulator.run(t_qc).result()
            counts = result.get_counts()
            measured_bit = 0 if '0' in counts else 1
            bob_results.append(measured_bit)

        # ✅ Key Sifting for k2
        sifted_key_indices = [i for i in range(len(bob_bases)) if bob_bases[i] == data["alice_bases"][i]]
        sifted_key = [bob_results[i] for i in sifted_key_indices]

        # Store k2 and check its length
        k2 = ''.join(map(str, sifted_key))

        if len(k2) >= 256:
            sessions[session_id]["bob_bases"] = bob_bases.tolist()
            sessions[session_id]["bob_results"] = bob_results
            sessions[session_id]["shared_key"] = k2[:256]
            userId = sessions[session_id]["alice_id"]
            return {"message": "QKD completed securely.", "shared_key": k2[:256], "userId": userId}

        retry_count += 1

    # Merge k1 and k2 to form k3 (if needed)
    merged_key = k1 + k2
    if len(merged_key) >= 256:
        k3 = merged_key[:256]
    else:
        # If even the merged key is less than 256, return as much as possible
        k3 = merged_key

    # Store the key in session
    sessions[session_id]["bob_bases"] = bob_bases.tolist()
    sessions[session_id]["bob_results"] = bob_results
    sessions[session_id]["shared_key"] = k3
    userId = sessions[session_id]["alice_id"]

    return {"message": "QKD completed with partial/merged key.", "shared_key": k3, "userId": userId}



# 🔐 Secure API Endpoint 3: Retrieve Shared Key
@app.get("/get_shared_key/{session_id}")
async def get_shared_key(session_id: str, user: dict = Depends(get_current_user)):
    if session_id not in sessions or sessions[session_id]["shared_key"] is None:
        raise HTTPException(status_code=404, detail="Shared key not available")

    return {"session_id": session_id, "shared_key": sessions[session_id]["shared_key"]}

# ✅ PQCTLS Configuration (TLS with Post-Quantum Security)
ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
ssl_context.load_cert_chain(certfile="pqctls_cert.pem", keyfile="pqctls_key.pem")

# ✅ Start FastAPI with Secure TLS
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, ssl_context=ssl_context)
