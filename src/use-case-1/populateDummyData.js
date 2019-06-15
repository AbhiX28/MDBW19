db = db.getSiblingDB('mdbw');

for (var year = 2018; year < 2020; year++) {

  for (var m = 1; m < 13; m++) {
    
    var month = m.toString();
    if (m < 10) {
      month = '0' + month;
    }
    
    var monthEnd = 30;
    if (m % 2) {
      monthEnd = 31;
    }
    if (m === 2) {
      monthEnd = 29;
    }
    
    for (var d = 1; d <= monthEnd; d++) {
      
      var day = d.toString();
      if (d < 10) {
        day = '0' + day;
      }

      var randomVolume = Math.floor(Math.random() * 400) + 1;
      for (var v = 1; v <= randomVolume; v++) {
        
        var randomNumber = Math.floor(Math.random()*100);
        isPrivate = randomNumber%9 ? true : false;
        
        const insertionObj = {
          "_id" : `9e22511a-e81d-43b4-99bc-${Math.floor(Math.random()*12345678)}5b61e1${month}${day}`,
          "customerId" : Math.floor(Math.random()*1000),
          "storeId" : Math.floor(Math.random()*1000),
          "orderNo" : Math.floor(Math.random()* 238).toString() + Math.floor(Math.random()*471).toString(),
          "qty" : Math.floor(Math.random()* 30),
          "totalAmount" : Math.floor(Math.random()*12345),
          "saleDate" : ISODate(`${year}-${month}-${day}T11:44:00Z`),
        }

        db.getCollection('abcSales').insert(insertionObj);

      }
    }
  }
}
