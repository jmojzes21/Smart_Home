package jmojzes21.smart_home_backend.logic;

import jakarta.enterprise.context.RequestScoped;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

@RequestScoped
public class CryptoService {

  public byte[] getRandomBytes(int size) {
    byte[] buffer = new byte[size];
    var random = new SecureRandom();
    random.nextBytes(buffer);
    return buffer;
  }

  public byte[] getSha256Hmac(byte[] key, byte[] input) {
    final String algorithm = "HmacSHA256";
    try {
      var keySpec = new SecretKeySpec(key, algorithm);
      var mac = Mac.getInstance(algorithm);
      mac.init(keySpec);
      return mac.doFinal(input);
    } catch (NoSuchAlgorithmException | InvalidKeyException e) {
      throw new RuntimeException(e);
    }
  }

}
