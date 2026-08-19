import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user != null && (_user!['isAdmin'] == true || _user!['role'] == 'admin' || _user!['role'] == 'ADMIN');

  List<dynamic> _tournaments = [];
  List<dynamic> get tournaments => _tournaments;

  List<dynamic> _myTeams = [];
  List<dynamic> get myTeams => _myTeams;

  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? get wallet => _wallet;

  List<dynamic> _notifications = [];
  List<dynamic> get notifications => _notifications;

  List<dynamic> _adminPlayers = [];
  List<dynamic> get adminPlayers => _adminPlayers;

  List<dynamic> _withdrawals = [];
  List<dynamic> get withdrawals => _withdrawals;

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
      final res = await ApiService.post('/api/auth/login', {
        'identifier': identifier,
        'password': password,
      }, auth: false);
      
      String? token = res['access_token'] ?? res['token'];
      if (token != null) {
        await ApiService.setToken(token);
        await checkAuth();
      } else {
        throw Exception('Login failed: No token received');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/auth/register', data, auth: false);
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
    _notifications = [];
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      // Public Data
      final tRes = await ApiService.get('/api/tournaments', auth: false);
      _tournaments = tRes['tournaments'] ?? tRes;

      if (_user != null) {
        // Private Data
        final wRes = await ApiService.get('/api/player/wallet');
        _wallet = wRes;

        final teamRes = await ApiService.get('/api/teams/my');
        _myTeams = teamRes['teams'] ?? teamRes;

        final notifRes = await ApiService.get('/api/notifications');
        _notifications = notifRes['notifications'] ?? notifRes;

        final drawRes = await ApiService.get('/api/player/withdrawals');
        _withdrawals = drawRes['withdrawals'] ?? drawRes;

        if (isAdmin) {
          final pRes = await ApiService.get('/api/admin/players');
          _adminPlayers = pRes['players'] ?? pRes;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing data: $e');
    }
  }

  // Tournament Actions
  Future<void> joinTournament(String tournamentId, String teamId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/registrations/create', {
        'tournamentId': tournamentId,
        'teamId': teamId,
      });
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Team Actions
  Future<void> createTeam(String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/teams', {'name': name});
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Wallet Actions
  Future<void> requestWithdrawal(double amount, String upiId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/player/withdrawal', {
        'amount': amount,
        'upiId': upiId,
      });
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> topupWallet(double amount, String utrNumber) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/player/wallet/topup-request', {
        'amount': amount,
        'utrNumber': utrNumber,
      });
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin Actions
  Future<void> adminUpdateUser(String playerId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Using generic player update route
      await ApiService.put('/api/admin/players/$playerId', data);
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminBanUser(String playerId, String reason, String type) async {
    try {
      _isLoading = true;
      notifyListeners();
      await ApiService.post('/api/admin/players/$playerId/ban', {
        'reason': reason,
        'banType': type,
      });
      await fetchUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
