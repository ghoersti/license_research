//TODO: Figure out popcorn straws
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'demoLicense.dart' as al;
import '../utils/utils.dart' as utils;

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];
// TODO: implement the rest of the rest functions.
// The data store/ DB will change immediatley from files
// So will not be bothering with the implementation for files

createProduct(Map<String, String> h, String product_name, String product_url,
    {List<String> platforms = const ["Darwin", "not_darwin"]}) async {
  utils.createDirectories();
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/products');
  var body = convert.json.encode({
    "data": {
      "type": "products",
      "attributes": {
        "name": "$product_name",
        "url": "$product_url",
        "platforms": platforms
      }
    }
  });

  var response = await http.post(url, headers: h, body: body);
  if (response.statusCode == 201) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    print("\n");
    final id = jsonResponse['data']['id'];
    utils.writeFile('../data/products/$id.json', jsonResponse);

    return jsonResponse;
  } else {
    print('Request failed status : ${response.body}.');
  }
}

void main() async {
  //TODO: This is broken not sure why the stdin is bleeding through to the next call
  String pname = utils.readStdin('Product Name');
  // String purl = utils.readStdin('Product URL');
  String purl = 'https://test.com';
  print("CREATING PRODUCT \n");
  createProduct(head, pname, purl);
}
