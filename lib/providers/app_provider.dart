import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user != null && (_user!['isAdmin'] == true || _user!['role'] == 'admin');

  List<dynamic> _tournaments = [];
  List<dynamic> get tournaments => _tournaments;

  List<dynamic> _myTeams = [];
  List<dynamic> get myTeams => _myTeams;

  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? get wallet => _wallet;

  List<dynamic> _adminPlayers = [];
  List<dynamic> get adminPlayers => _adminPlayers;

  Future<void> init() async {
    await ApiService.init();
    await checkAuth();
  }

  Future<void> checkAuth() async {
    try {
      _isLoading = true;
      notifyListeners();
      final res = await ApiService.get('/api/player/profile');
      _user = res;
      await fetchUserData();
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Assuming login endpoint or token generation
      final res = await ApiService.post('/api/auth/login', {
        'identifier': identifier,
        'password': password,
      }, auth: false);
      
      if (res['access_token'] != null) {
        await ApiService.setToken(res['access_token']);
      } else if (res['token'] != null) {
        await ApiService.setToken(res['token']);
      }
      await checkAuth();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _tournaments = [];
    _myTeams = [];
    _wallet = null;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      final tRes = await ApiService.get('/api/tournaments', auth: false);
      if (tRes['tournaments'] is List) {
        _tournaments = tRes['tournaments'];
      } else if (tRes is List) {
        _tournaments = tRes;
      }

      if (_user != null) {
        try {
          final wRes = await ApiService.get('/api/player/wallet');
          _wallet = wRes;
        } catch (_) {}

        try {
          final teamRes = await ApiService.get('/api/teams/my');
          if (teamRes['teams'] is List) {
            _myTeams = teamRes['teams'];
          } else if (teamRes is List) {
            _myTeams = teamRes;
          }
        } catch (_) {}

        if (isAdmin) {
          try {
            final pRes = await ApiService.get('/api/admin/players');
            if (pRes['players'] is List) {
              _adminPlayers = pRes['players'];
            } else if (pRes is List) {
              _adminPlayers = pRes;
            }
          } catch (_) {}
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> adminUpdateUser(String playerId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.put('/api/admin/players/$playerId', data);
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
