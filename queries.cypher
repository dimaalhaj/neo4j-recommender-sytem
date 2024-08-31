// Step 1 LOAD DATA FROM REVIEWS
LOAD CSV WITH HEADERS FROM 'file:///reviews.csv' AS row
MERGE (u:User {reviewerID: row.reviewerID})
MERGE (p:Product {productID: row.asin})
CREATE (u)-[:REVIEWED {rating: row.rating, sentimentScore: row.average_sentiment_rating, sentimentLabel: row.average_sentiment_label}]->(p);


// STEP 2 LOAD DATA FROM META AND PROPERTY CATEGORY 1
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MERGE (p:Product {productID: row.asin})
MERGE (c:Category {name: row.Category1})
CREATE (p)-[:HAS_CATEGORY]->(c);


// STEP 3 LOAD META PROPERTY CATEGORY 2
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p:Product {productID: row.asin})
WHERE row.Category2 IS NOT NULL
MERGE (c:Category {name: row.Category2})
CREATE (p)-[:HAS_CATEGORY]->(c);


// STEP 4 LOAD META PROPERTY CATEGORY 3
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p:Product {productID: row.asin})
WHERE row.Category3 IS NOT NULL
MERGE (c:Category {name: row.Category3})
CREATE (p)-[:HAS_CATEGORY]->(c);


// STEP 5 LOAD META PROPERTY CATEGORY 4
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p:Product {productID: row.asin})
WHERE row.Category4 IS NOT NULL
MERGE (c:Category {name: row.Category4})
CREATE (p)-[:HAS_CATEGORY]->(c);


// STEP 6 LOAD META PROPERTY ALSO BUY
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p1:Product {productID: row.asin})
WHERE size(row.also_buy) > 0
FOREACH (related IN split(row.also_buy, ',') |
    MERGE (p2:Product {productID: related})
    CREATE (p1)-[:SIMILAR_TO]->(p2)
)


// STEP 7 LOAD META PROPERTY ALSO VIEW
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p1:Product {productID: row.asin})
WHERE size(row.also_view) > 0
FOREACH (related IN split(row.also_view, ',') |
    MERGE (p2:Product {productID: related})
    CREATE (p1)-[:SIMILAR_TO]->(p2)
)


// STEP 8 LOAD META AVERAGE RATING
LOAD CSV WITH HEADERS FROM 'file:///meta.csv' AS row
MATCH (p:Product {productID: row.asin})
SET p.avgRating = row.avg_rating


// STEP 9 CREATE PROJECTION
CALL gds.graph.project(
  'pProduct',
  ['Product', 'Category', 'User'],
  ['REVIEWED', 'HAS_CATEGORY', 'SIMILAR_TO']
)


// STEP 10 FASTRP EMBEDDING
CALL gds.fastRP.mutate('pProduct',
  {
    embeddingDimension: 256,
    randomSeed: 42,
    mutateProperty: 'embedding',
    iterationWeights: [0.8, 1, 1, 1]
  }
)
YIELD nodePropertiesWritten


// STEP 11 WRITE EMBEDDINGS TO PRODUCTS
CALL gds.graph.writeNodeProperties('pProduct', ["embedding"], ["Product"])


// STEP 12 CREATE GRAPH PROJECTION OF EMBEDDED PRODUCTS
CALL gds.graph.project(
    'graph-projection',
    {
        Product: {properties: 'embedding'}
    },
    '*'
)


// STEP 13 KNN FOR PRODUCTS SIMILARITY
CALL gds.knn.write('graph-projection', {
    nodeProperties: ['embedding'],
    writeRelationshipType: "NEIGHBOR",
    writeProperty: "score"
})
YIELD nodesCompared, relationshipsWritten, similarityDistribution
RETURN nodesCompared, relationshipsWritten, similarityDistribution.mean as meanSimilarity


// STEP 14 FETCH SIMILAR PRODUCTS ALONG WITH SIMILARITY SCORE
MATCH (p1:Product)-[r:NEIGHBOR]->(p2:Product)
RETURN p1.productID as product1, p2.productID as product2, r.score as similarity
ORDER BY similarity DESCENDING, product1, product2


// STEP 15 RELATIONSHIP BETWEEN 2 PRODUCTS
MATCH p=(p1:Product {productID: "0375848207"})--()--(p2:Product {productID: "B00O8UQTSA"}) RETURN p

