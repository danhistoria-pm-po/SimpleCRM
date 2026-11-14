// lib/features/follow_up/controllers/follow_up_controller.dart
import 'package:flutter/foundation.dart';
import '../models/follow_up_model.dart';
import '../repositories/follow_up_repository.dart';

class FollowUpController extends ChangeNotifier {
  final FollowUpRepository _repository;

  FollowUpController({FollowUpRepository? repository})
      : _repository = repository ?? FollowUpRepository();

  List<FollowUpModel> followUps = [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  Future<bool> loadFollowUps({bool silent = false}) async {
    if (!silent && followUps.isEmpty) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = null;
    notifyListeners();

    try {
      followUps = await _repository.getFollowUps();
      return true;
    } catch (e) {
      errorMessage =
          'Erro ao carregar follow-ups: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      return false;
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> addFollowUp(FollowUpModel followUp) async {
    try {
      errorMessage = null;
      await _repository.addFollowUp(followUp);
      return await loadFollowUps(silent: true);
    } catch (e) {
      errorMessage =
          'Erro ao adicionar follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Atualização otimista: não troca a tela por spinner e reverte em caso de falha
  Future<bool> updateFollowUp(FollowUpModel followUp) async {
    final previousList = List<FollowUpModel>.from(followUps);
    final index = followUps.indexWhere((f) => f.id == followUp.id);

    if (index != -1) {
      followUps[index] = followUp;
      errorMessage = null;
      notifyListeners();
    }

    try {
      await _repository.updateFollowUp(followUp);
      return true;
    } catch (e) {
      followUps = previousList;
      errorMessage =
          'Erro ao atualizar follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Alterna o estado de "Recebido" e limpa receivedDate quando desmarcado
  Future<bool> toggleReceived(FollowUpModel followUp, bool isReceived) async {
    final updated = followUp.copyWith(
      isReceived: isReceived,
      status: isReceived ? 'concluido' : 'pendente',
      receivedDate: isReceived ? DateTime.now() : null,
      clearReceivedDate: !isReceived,
    );
    return updateFollowUp(updated);
  }

  Future<bool> deleteFollowUp(String id) async {
    final previousList = List<FollowUpModel>.from(followUps);
    followUps.removeWhere((f) => f.id == id);
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteFollowUp(id);
      return true;
    } catch (e) {
      followUps = previousList;
      errorMessage =
          'Erro ao excluir follow-up: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }
}
