import 'package:http/http.dart' as http;
import 'package:zipkart_firebase/Constants/Constant.dart';

class UserApiService{

  Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String imagePath,
  }) async {
    // Define the API endpoint
      final url = Uri.parse(Constant.BASEURL + Constant.USER + Constant.REGISTER);

      // Make the POST request with dynamic data
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "name": "$name",
          "email": "$email",
          "password": "$password",
          "role": "$role",
          "phoneNumber": "$phoneNumber",
          "imagePath": "$imagePath"
        }
      ''',
      );
      return response;
  }


}
