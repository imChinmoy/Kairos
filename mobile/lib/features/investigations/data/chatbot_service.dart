import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'investigation_repository.dart';

class ChatbotService {
  final Dio _dio;
  final InvestigationRepository _investigationRepository;

  ChatbotService(this._dio, this._investigationRepository);

  Future<String> askChatbot(String investigationId, String message) async {
    try {
      final fullData = await _investigationRepository.getRawInvestigation(investigationId);
      
      final response = await _dio.post(
        'https://oiltraceai-chatbot.onrender.com/chat',
        data: {
          'message': message,
          'investigation_data': fullData,
        },
      );
      
      if (response.data is Map && response.data.containsKey('response')) {
        return response.data['response'].toString();
      } else if (response.data is Map && response.data.containsKey('reply')) {
        return response.data['reply'].toString();
      } else if (response.data is Map && response.data.containsKey('message')) {
        return response.data['message'].toString();
      } else if (response.data is Map && response.data.containsKey('answer')) {
        return response.data['answer'].toString();
      }
      return response.data.toString();
    } catch (e) {
      throw Exception('Failed to communicate with chatbot: $e');
    }
  }
}

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  final dio = Dio();
  final investigationRepository = ref.watch(investigationRepositoryProvider);
  return ChatbotService(dio, investigationRepository);
});
