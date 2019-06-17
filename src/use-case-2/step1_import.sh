#!/bin/bash

echo "Mongo import process begins";
BASEPATH=`dirname $0`
baseFolder=${BASEPATH%%/}/legacy_data/

connectionString="mongodb://localhost:27017/mdbw";

#Schema Definition CSV files
sales="stor_id.int64(),ord_num.string(),ord_date.auto(),qty.int64(),payterms.string(),title_id.string()";
stores="stor_id.int64(),stor_name.string(),stor_address.string(),city.string(),state.string(),zip.string()";
titles="title_id.string(),title.string(),type.string(),price.double()";

#Dropping existing Temp Collections
mongo "$connectionString" --eval "db.sales.drop()" ;
mongo "$connectionString" --eval "db.stores.drop()" ;
mongo "$connectionString" --eval "db.titles.drop()" ;


#Creating Indexes to speed up operations down the line
#Creating Indexes on blank collections is always a better practice especially of data size is huge
mongo "$connectionString" --eval "db.getCollection('sales').createIndex({ 'stor_id': 1 }, { 'background': true })";
mongo "$connectionString" --eval "db.getCollection('sales').createIndex({ 'ord_num': 1 }, { 'background': true })";
mongo "$connectionString" --eval "db.getCollection('stores').createIndex({ 'stor_id': 1 }, { 'background': true })";
mongo "$connectionString" --eval "db.getCollection('titles').createIndex({ 'title_id': 1 }, { 'background': true })";

#Import CSV data into Temp mongo collections
mongoimport --uri "$connectionString" -c "sales" --type csv --file "${baseFolder}sales.csv" --fields "$sales" --ignoreBlanks --columnsHaveTypes ;
mongoimport --uri "$connectionString" -c "stores" --type csv --file "${baseFolder}stores.csv" --fields "$stores" --ignoreBlanks --columnsHaveTypes ;
mongoimport --uri "$connectionString" -c "titles" --type csv --file "${baseFolder}titles.csv" --fields "$titles" --ignoreBlanks --columnsHaveTypes ;

