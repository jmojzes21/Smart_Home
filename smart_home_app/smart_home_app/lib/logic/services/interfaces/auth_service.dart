abstract class IAuthService {
  Future<void> login(String hostname, String username, String password, bool stayLoggedIn);
  Future<bool> loadSession();
  Future<void> logout();
}
