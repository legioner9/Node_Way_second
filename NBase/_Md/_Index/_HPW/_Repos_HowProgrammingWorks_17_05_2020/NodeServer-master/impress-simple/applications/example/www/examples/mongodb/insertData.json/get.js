(client, callback) => {
  dbAlias.testCollection.insert(client.query, function(err) {
    callback(!err);
  });
}