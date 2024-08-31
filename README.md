# Content-based Recommender System Using Neo4j Native Graph Database

The Dataset is a subset of the Amazon cell phones and accessories product reviews-2018.

## Refer to reviews.csv file 
Contains data on the reviews written by the users, some original columns are removed, and new columns are added as a result of preprocessing. Each review includes the following information:
1. reviewerID: User ID.
2. asin: The rated product ID.
3. reviewText: Textual review content.
4. rating: The numeric rating of the product given by the user in the range of [0,1].
5. label: Positive/Negative/Neutral based on rating value.
6. average_sentiment_rating: Averaged score of the user rating and the sentiment polarity of the textual review.
7. average_sentiment_label: Positive/Negative/Neutral based on average_sentiment_rating value.
8. unixReviewTime: Time of the review in UNIX format.


## Refer to meta.csv file 
Supporting information with more details on the products provided to the users, some irrelevant columns were removed, and an average score column is added.
1. asin: The product ID.
2. title: The product name.
3. description: Description of the product.
4. also_buy: List of products usually bought with the specified product.
5. also_view: List of products usually viewed along with the specified product.
6. brand: Brand name of the product.
7. Category[1-4]: The categories a product can belong to (minimum 1, maximum 4).
8. avg_rating: The average rating given to a product from all users that rated it.


## Refer to queries.cypher file 
Contains all the queries that could be run on Neo4j to reproduce the results achieved.
