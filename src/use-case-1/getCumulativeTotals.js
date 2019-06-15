db.getCollection('abcSales').mapReduce(
  function () {

    var pad = function pad(n, width, z) {
      z = z || '0';
      n = n + '';
      return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
    };

    var calDate = this.saleDate;
    var dateInYearMonth = calDate.getFullYear() + "-" + pad(calDate.getMonth() + 1, 2, 0) + "-" + pad(calDate.getDate(), 2, 0);
    emit(dateInYearMonth, 1); // Grouping data by Date
  },

  function (key, values) {
    return Array.sum(values); //Date wise Totals
  },

  {
    "scope": { "totalAmount": 0 },
    "finalize": function (key, value) {
      totalAmount += value;
      return totalAmount; // Cumulative Totals
    },
    "out": { "inline": 1 },
    "query": {
      "saleDate": {
        "$gte": ISODate("2019-06-01T00:00:00.000Z"),
        "$lte": ISODate("2020-06-18T00:00:00.000Z")
      }
    },
    $sort: { createdDate: 1 }
  }
)
