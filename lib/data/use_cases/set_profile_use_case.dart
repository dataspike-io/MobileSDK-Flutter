import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';

class SetProfileUseCase {
  final IDataspikeRepository dataspikeRepository;

  SetProfileUseCase({
    required this.dataspikeRepository,
  });

  Future<MessageState> call(ProfileFieldsRequestBody body) async {
    return await dataspikeRepository.setProfileFields(body);
  }
}