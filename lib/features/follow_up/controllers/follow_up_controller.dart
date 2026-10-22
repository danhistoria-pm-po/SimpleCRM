import 'package:flutter/foundation.dart';
import '../models/follow_up_model.dart';
import '../repositories/follow_up_repository.dart';

class FollowUpController extends ChangeNotifier {
  final FollowUpRepository _repository = FollowUpRepository();

  List<FollowUpModel> followUps = [];
  bool isLoading = false;

  // Carregar todos os follow-ups da base de dados
  Future<void> loadFollowUps() async {
    isLoading = true;
    notifyListeners();

    try {
      followUps = await _repository.getFollowUps();
    } catch (e) {
      debugPrint('Erro ao carregar follow-ups: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar um novo follow-up
  Future<void> addFollowUp(FollowUpModel followUp) async {
    try {
      await _repository.addFollowUp(followUp);
      await loadFollowUps();
    } catch (e) {
      debugPrint('Erro ao adicionar follow-up: $e');
    }
  }

  // Atualizar um follow-up existente
  Future<void> updateFollowUp(FollowUpModel followUp) async {
    try {
      await _repository.updateFollowUp(followUp);
      await loadFollowUps();
    } catch (e) {
      debugPrint('Erro ao atualizar follow-up: $e');
    }
  }

  // Alternar o estado de "Recebido" (e registar a data automaticamente)
  Future<void> toggleReceived(FollowUpModel followUp, bool isReceived) async {
    final updated = followUp.copyWith(
      isReceived: isReceived,
      receivedDate: isReceived ? DateTime.now() : null,
    );
    await updateFollowUp(updated);
  }

  // Eliminar um follow-up
  Future<void> deleteFollowUp(String id) async {
    try {
      await _repository.deleteFollowUp(id);
      await loadFollowUps();
    } catch (e) {
      debugPrint('Erro ao eliminar follow-up: $e');
    }
  }
}