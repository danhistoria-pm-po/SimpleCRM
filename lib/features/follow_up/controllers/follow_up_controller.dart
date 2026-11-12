// lib/features/follow_up/controllers/follow_up_controller.dart
import 'package:flutter/foundation.dart';
import '../models/follow_up_model.dart';
import '../repositories/follow_up_repository.dart';

class FollowUpController extends ChangeNotifier {
  final FollowUpRepository _repository = FollowUpRepository();

  List<FollowUpModel> followUps = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadFollowUps() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      followUps = await _repository.getFollowUps();
    } catch (e) {
      errorMessage = 'Erro ao carregar follow-ups: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFollowUp(FollowUpModel followUp) async {
    try {
      await _repository.addFollowUp(followUp);
      await loadFollowUps();
      return true;
    } catch (e) {
      errorMessage = 'Erro ao adicionar follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFollowUp(FollowUpModel followUp) async {
    try {
      await _repository.updateFollowUp(followUp);
      await loadFollowUps();
      return true;
    } catch (e) {
      errorMessage = 'Erro ao atualizar follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleReceived(FollowUpModel followUp, bool isReceived) async {
    final updated = followUp.copyWith(
      isReceived: isReceived,
      status: isReceived ? 'concluido' : 'pendente',
      receivedDate: isReceived ? DateTime.now() : null,
    );
    await updateFollowUp(updated);
  }

  Future<bool> deleteFollowUp(String id) async {
    try {
      await _repository.deleteFollowUp(id);
      followUps.removeWhere((f) => f.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erro ao eliminar follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }
}
