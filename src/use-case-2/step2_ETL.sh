#!/bin/bash

echo "Mongo ETL process begins";

connectionString="mongodb://localhost:27017/mdbw";


echo "****************Update Lookup Values for sales*********************";
## sales
mongo "$connectionString" --eval "
db.getCollection('sales').aggregate([{
    '\$addFields': {
      'timestamp': new Date(),
      '_id': '\$ord_num',
      'payterms': {
        '\$switch': {
          'branches': [{
              case: {
                '\$eq': ['\$payterms', 'ON invoice']
              },
              'then': 'Invoice'
            },
            {
              case: {
                '\$eq': ['\$payterms', 'Net 30']
              },
              'then': 'Cash'
            },
            {
              case: {
                '\$eq': ['\$payterms', 'Net 60']
              },
              'then': 'Credit Card'
            }
          ],
          'default': null
        }
      }

    }
  },
  {
    '\$out': 'sales'
  }
], {
  hint: {
    'ord_num': 1
  }
}, {
  allowDiskUse: true
})";

## The $addFields stage is equivalent to a $project stage that explicitly specifies all existing fields in the input documents and adds the new fields.


## stores
echo "****************No Lookup values in stores, so just add timestamp & update stor_id*********************";
mongo "$connectionString" --eval "
db.getCollection('stores').aggregate([{
    '\$addFields': {
      '_id': '\$stor_id',
      'timestamp': new Date()
    }
  },
  {
    '\$out': 'stores'
  }
], {
  hint: {
    'stor_id': 1
  }
}, {
  allowDiskUse: true
})";



## titles
echo "****************Update Lookup Values for titles*********************";
mongo "$connectionString" --eval "
db.getCollection('titles').aggregate([{
    '\$addFields': {
      '_id': '\$title_id',
      'timestamp': new Date(),
      'type': {
        '\$switch': {
          'branches': [{
              case: {
                '\$eq': ['\$type', 'popular_comp']
              },
              'then': 'Computer'
            },
            {
              case: {
                '\$eq': ['\$type', 'business']
              },
              'then': 'Business'
            },
            {
              case: {
                '\$eq': ['\$type', 'mod_cook']
              },
              'then': 'Modern Cooking'
            },
            {
              case: {
                '\$eq': ['\$type', 'UNDECIDED']
              },
              'then': 'TBD'
            },
            {
              case: {
                '\$eq': ['\$type', 'psychology']
              },
              'then': 'Psychology'
            },
            {
              case: {
                '\$eq': ['\$type', 'trad_cook']
              },
              'then': 'Traditional Cooking'
            }
          ],
          'default': null
        }
      }
    }
  },
  {
    '\$out': 'titles'
  }
], {
  hint: {
    'title_id': 1
  }
}, {
  allowDiskUse: true
})";


mongo "$connectionString" --eval "db.getCollection('titles').updateMany({'type' : null}, { '\$unset' : { 'type' : 1 }})";

## Consolidate all data into single collection
echo "****************Conslidate All data in sales*********************";
mongo "$connectionString" --eval "
db.getCollection('sales').aggregate([{
    '\$lookup': {
      'from': 'stores',
      'localField': 'stor_id',
      'foreignField': 'stor_id',
      'as': 'store'
    }
  },
  {
    '\$lookup': {
      'from': 'titles',
      'localField': 'title_id',
      'foreignField': 'title_id',
      'as': 'title'
    }
  },
  {
    '\$addFields': {
      'timestamp': new Date()
    }
  },
  {
    '\$unwind': {
      path: '\$title',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    '\$out': 'newSalesData'
  }
], {
  hint: {
    'ord_num': 1
  }
}, {
  allowDiskUse: true
})";

echo "****************Create Index for newSalesData*********************";
mongo "$connectionString" --eval "db.getCollection('newSalesData').createIndex({ 'ord_num': 1 }, { 'background': true })";

# Create Audit Log 
echo "****************Create Audit Log*********************";
mongo "$connectionString" --eval "
db.getCollection('newSalesData').find({}).forEach(function(doc){
   delete doc._id;
   db.getCollection('salesAuditLog').insert(doc);
});";

# Upsert / Merge data into Master collection
echo "****************Upsert / Merge data into Master collection - osPlacesMaster*********************";
mongo "$connectionString" --eval "
db.getCollection('newSalesData').find({}).forEach(function(doc){
    doc._id = doc.ord_num;
    db.getCollection('salesMaster').update({_id: doc.ord_num},doc, { upsert: true });
});";


# Delete intermediary collections

mongo "$connectionString" --eval "db.sales.drop()" ;
mongo "$connectionString" --eval "db.stores.drop()" ;
mongo "$connectionString" --eval "db.titles.drop()" ;
mongo "$connectionString" --eval "db.newSalesData.drop()" ;
