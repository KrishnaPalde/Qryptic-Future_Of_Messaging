use pqcrypto_kem::kyber768; // NIST PQC Standard
use pqcrypto_traits::kem::*;
use std::ptr;

#[no_mangle]
pub extern "C" fn generate_kyber_keypair() -> *mut u8 {
    let (pk, sk) = kyber768::keypair();
    let mut keypair_bytes = vec![];
    keypair_bytes.extend(pk.as_bytes());
    keypair_bytes.extend(sk.as_bytes());

    let key_ptr = keypair_bytes.as_mut_ptr();
    std::mem::forget(keypair_bytes);
    key_ptr
}

#[no_mangle]
pub extern "C" fn encapsulate_kyber(public_key: *const u8) -> *mut u8 {
    let pk_bytes = unsafe { std::slice::from_raw_parts(public_key, kyber768::PUBLIC_KEY_BYTES) };
    let pk = kyber768::PublicKey::from_bytes(pk_bytes).unwrap();

    let (ciphertext, shared_secret) = kyber768::encapsulate(&pk);
    let mut data = vec![];
    data.extend(ciphertext.as_bytes());
    data.extend(shared_secret.as_bytes());

    let ptr = data.as_mut_ptr();
    std::mem::forget(data);
    ptr
}

#[no_mangle]
pub extern "C" fn decapsulate_kyber(secret_key: *const u8, ciphertext: *const u8) -> *mut u8 {
    let sk_bytes = unsafe { std::slice::from_raw_parts(secret_key, kyber768::SECRET_KEY_BYTES) };
    let ct_bytes = unsafe { std::slice::from_raw_parts(ciphertext, kyber768::CIPHERTEXT_BYTES) };

    let sk = kyber768::SecretKey::from_bytes(sk_bytes).unwrap();
    let ct = kyber768::Ciphertext::from_bytes(ct_bytes).unwrap();

    let shared_secret = kyber768::decapsulate(&ct, &sk);
    let ptr = shared_secret.as_mut_ptr();
    std::mem::forget(shared_secret);
    ptr
}
