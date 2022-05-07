// final r2 = await http.get(Uri.parse(
    //   "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/24?token=$token&f=json"
    // ));

    //var j = jsonDecode(r2.body);
    //log(j.toString());

    // Map<String, dynamic> body = {
    //   "geometry": {
    //     "x":-41.4005,
    //     "y":147.1379
    //   },
    //   "attributes": {
    //     "VERS":1,
    //     "ASSNBRI":109111
    //   }
    // };

    // var list = [];
    // list.add(body);

    // var q = http.MultipartRequest("POST", Uri.parse(
    //   "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/0/addFeatures?token=$token&f=json"
    //   ));

    // q.fields['features'] = jsonEncode(list);
    // var r = await q.send();

    // var str = await http.Response.fromStream(r);
    // log(str.body);
