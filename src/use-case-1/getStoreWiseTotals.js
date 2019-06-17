// Simple Grouping & Sum of Qty & Value on StoreID
db.getCollection('abcSales').aggregate(
  [
    {
      "$match": {
        "saleDate": {
          "$gte": ISODate("2019-06-01T00:00:00.000Z"),
          "$lte": ISODate("2019-06-18T00:00:00.000Z")
        }
      }
    },
    {
      "$group": {
        "_id": "$storeId",
        "totalqty": {
          "$sum": "$qty",
        },
        "totalValue": {
          "$sum": "$totalAmount",
        }
      }
    },
    {
      "$sort": { "_id": 1 }
    }
  ]
)

// Total count per Store ID