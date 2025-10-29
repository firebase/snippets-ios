//
//  Copyright (c) 2025 Google LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import FirebaseFirestore
import CoreLocation

public class PipelineSnippets {

  lazy var db = {
    Firestore.firestore(database: "enterprise")
  }()

  public func runAllSnippets() {
    pipelineConcepts()
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#concepts
  func pipelineConcepts() {
    // [START pipeline_concepts]
    let pipeline = db.pipeline()
      // Step 1: Start a query with collection scope
      .collection("cities")
      // Step 2: Filter the collection
      .where(Field("population").greaterThan(100000))
      // Step 3: Sort the remaining documents
      .sort([Field("name").ascending()])
      // Step 4: Return the top 10. Note applying the limit earlier in the pipeline would have
      // unintentional results.
      .limit(10)
    // [END pipeline_concepts]
    print(pipeline)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#initialization
  func pipelineInitialization() {
    // [START pipeline_initialization]
    let firestore = Firestore.firestore(database: "enterprise")
    let pipeline = firestore.pipeline()
    // [END pipeline_initialization]
    print(pipeline)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#field_vs_constant_references/
  func fieldVsConstants() {
    // [START field_or_constant]
    let pipeline = db.pipeline()
      .collection("cities")
      .where(Field("name").equal(Constant("Toronto")))
    // [END field_or_constant]
    print(pipeline)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#input_stages
  func inputStages() async throws {
    // [START input_stages]
    var results: Pipeline.Snapshot

    // Return all restaurants in San Francisco
    results = try await db.pipeline().collection("cities/sf/restaurants").execute()

    // Return all restaurants
    results = try await db.pipeline().collectionGroup("restaurants").execute()

    // Return all documents across all collections in the database (the entire database)
    results = try await db.pipeline().database().execute()

    // Batch read of 3 documents
    results = try await db.pipeline().documents([
      db.collection("cities").document("SF"),
      db.collection("cities").document("DC"),
      db.collection("cities").document("NY")
    ]).execute()
    // [END input_stages]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#where
  func wherePipeline() async throws {
    // [START pipeline_where]
    var results: Pipeline.Snapshot

    results = try await db.pipeline().collection("books")
      .where(Field("rating").equal(5))
      .where(Field("published").lessThan(1900))
      .execute()

    results = try await db.pipeline().collection("books")
      .where(Field("rating").equal(5) && Field("published").lessThan(1900))
      .execute()
    // [END pipeline_where]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#aggregate_distinct
  func aggregateGroups() async throws {
    // [START aggregate_groups]
    let results = try await db.pipeline()
      .collection("books")
      .aggregate([
        Field("rating").average().as("avg_rating")
      ], groups: [
        Field("genre")
      ])
      .execute()
    // [END aggregate_groups]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#aggregate_distinct
  func aggregateDistinct() async throws {
    // [START aggregate_distinct]
    let results = try await db.pipeline()
      .collection("books")
      .distinct([
        Field("author").toUpper().as("author"),
        Field("genre")
      ])
      .execute()
    // [END aggregate_distinct]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#sort
  func sort() async throws {
    // [START sort]
    let results = try await db.pipeline()
      .collection("books")
      .sort([
        Field("release_date").descending(), Field("author").ascending()
      ])
      .execute()
    // [END sort]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#sort
  func sortComparison() {
    // [START sort_comparison]
    let query = db.collection("cities")
      .order(by: "state")
      .order(by: "population", descending: true)

    let pipeline = db.pipeline()
      .collection("books")
      .sort([
        Field("release_date").descending(), Field("author").ascending()
      ])
    // [END sort_comparison]
    print(query)
    print(pipeline)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#functions
  func functions() async throws {
    // [START functions_example]
    var results: Pipeline.Snapshot

    // Type 1: Scalar (for use in non-aggregation stages)
    // Example: Return the min store price for each book.
    results = try await db.pipeline().collection("books")
      .select([
        Field("current").logicalMinimum(["updated"]).as("price_min")
      ])
      .execute()

    // Type 2: Aggregation (for use in aggregate stages)
    // Example: Return the min price of all books.
    results = try await db.pipeline().collection("books")
      .aggregate([Field("price").minimum().as("min_price")])
      .execute()
    // [END functions_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#creating_indexes
  func creatingIndexes() async throws {
    // [START query_example]
    let results = try await db.pipeline()
      .collection("books")
      .where(Field("published").lessThan(1900))
      .where(Field("genre").equal("Science Fiction"))
      .where(Field("rating").greaterThan(4.3))
      .sort([Field("published").descending()])
      .execute()
    // [END query_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#existing_sparse_indexes
  func sparseIndexes() async throws {
    // [START sparse_index_example]
    let results = try await db.pipeline()
      .collection("books")
      .where(Field("category").like("%fantasy%"))
      .execute()
    // [END sparse_index_example]
    print(results)
  }

  func sparseIndexes2() async throws {
    // [START sparse_index_example_2]
    let results = try await db.pipeline()
      .collection("books")
      .sort([Field("release_date").ascending()])
      .execute()
    // [END sparse_index_example_2]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#covered_queries_secondary_indexes
  func coveredQuery() async throws {
    // [START covered_query]
    let results = try await db.pipeline()
      .collection("books")
      .where(Field("category").like("%fantasy%"))
      .where(Field("title").exists())
      .where(Field("author").exists())
      .select([Field("title"), Field("author")])
      .execute()
    // [END covered_query]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/overview#pagination
  func pagination() async throws {
    // [START pagination_not_supported_preview]
    // Existing pagination via `start(at:)`
    let query = db.collection("cities").order(by: "population").start(at: [1000000])

    // Private preview workaround using pipelines
    let pipeline = db.pipeline()
      .collection("cities")
      .where(Field("population").greaterThanOrEqual(1000000))
      .sort([Field("population").descending()])
    // [END pagination_not_supported_preview]
    print(query)
    print(pipeline)
  }

  // http://cloud.google.com/firestore/docs/pipeline/stages/input/collection#example
  func collectionStage() async throws {
    // [START collection_example]
    let results = try await db.pipeline()
      .collection("users/bob/games")
      .sort([Field("name").ascending()])
      .execute()
    // [END collection_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/input/collection_group
  func collectionGroupStage() async throws {
    // [START collection_group_example]
    let results = try await db.pipeline()
      .collectionGroup("games")
      .sort([Field("name").ascending()])
      .execute()
    // [END collection_group_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/input/database
  func databaseStage() async throws {
    // [START database_example]
    // Count all documents in the database
    let results = try await db.pipeline()
      .database()
      .aggregate([CountAll().as("total")])
      .execute()
    // [END database_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/input/documents
  func documentsStage() async throws {
    // [START documents_example]
    let results = try await db.pipeline()
      .documents([
        db.collection("cities").document("SF"),
        db.collection("cities").document("DC"),
        db.collection("cities").document("NY")
      ]).execute()
    // [END documents_example]
    print(results)
  }

  func replaceWithStage() async throws {
    // [START initial_data]
    try await db.collection("cities").document("SF").setData([
      "name": "San Francisco",
      "population": 800000,
      "location": [
        "country": "USA",
        "state": "California"
      ]
    ])
    try await db.collection("cities").document("TO").setData([
      "name": "Toronto",
      "population": 3000000,
      "province": "ON",
      "location": [
        "country": "Canada",
        "province": "Ontario"
      ]
    ])
    try await db.collection("cities").document("NY").setData([
      "name": "New York",
      "location": [
        "country": "USA",
        "state": "New York"
      ]
    ])
    try await db.collection("cities").document("AT").setData([
      "name": "Atlantis",
    ])
    // [END initial_data]

    // [START full_replace]
    let names = try await db.pipeline()
      .collection("cities")
      .replace(with: Field("location"))
      .execute()
    // [END full_replace]

    // [START map_merge_overwrite]
    // unsupported in client SDKs for now
    // [END map_merge_overwrite]
    print(names)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/sample#examples
  func sampleStage() async throws {
    // [START sample_example]
    var results: Pipeline.Snapshot

    // Get a sample of 100 documents in a database
    results = try await db.pipeline()
      .database()
      .sample(count: 100)
      .execute()

    // Randomly shuffle a list of 3 documents
    results = try await db.pipeline()
      .documents([
        db.collection("cities").document("SF"),
        db.collection("cities").document("NY"),
        db.collection("cities").document("DC"),
      ])
      .sample(count: 3)
      .execute()
    // [END sample_example]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/sample#examples_2
  func samplePercent() async throws {
    // [START sample_percent]
    // Get a sample of on average 50% of the documents in the database
    let results = try await db.pipeline()
      .database()
      .sample(percentage: 0.5)
      .execute()
    // [END sample_percent]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/union#examples
  func unionStage() async throws {
    // [START union_stage]
    let results = try await db.pipeline()
      .collection("cities/SF/restaurants")
      .where(Field("type").equal("Chinese"))
      .union(with: db.pipeline()
        .collection("cities/NY/restaurants")
        .where(Field("type").equal("Italian")))
      .where(Field("rating").greaterThanOrEqual(4.5))
      .sort([Field("__name__").descending()])
      .execute()
    // [END union_stage]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/union#examples
  func unionStageStable() async throws {
    // [START union_stage_stable]
    let results = try await db.pipeline()
      .collection("cities/SF/restaurants")
      .where(Field("type").equal("Chinese"))
      .union(with: db.pipeline()
          .collection("cities/NY/restaurants")
          .where(Field("type").equal("Italian")))
      .where(Field("rating").greaterThanOrEqual(4.5))
      .sort([Field("__name__").descending()])
      .execute()
    // [END union_stage_stable]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/unnest#examples
  func unnestStage() async throws {
    // [START unnest_stage]
    let results = try await db.pipeline()
      .database()
      .unnest(Field("arrayField").as("unnestedArrayField"), indexField: "index")
      .execute()
    // [END unnest_stage]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/stages/transformation/unnest#examples
  func unnestStageEmptyOrNonArray() async throws {
    // [START unnest_edge_cases]
    // Input
    // { identifier : 1, neighbors: [ "Alice", "Cathy" ] }
    // { identifier : 2, neighbors: []                   }
    // { identifier : 3, neighbors: "Bob"                }

    let results = try await db.pipeline()
      .database()
      .unnest(Field("neighbors").as("unnestedNeighbors"), indexField: "index")
      .execute()

    // Output
    // { identifier: 1, neighbors: [ "Alice", "Cathy" ], unnestedNeighbors: "Alice", index: 0 }
    // { identifier: 1, neighbors: [ "Alice", "Cathy" ], unnestedNeighbors: "Cathy", index: 1 }
    // { identifier: 3, neighbors: "Bob", index: null}
    // [END unnest_edge_cases]
    print(results)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#count
  func countFunction() async throws {
    // [START count_function]
    // Total number of books in the collection
    let countAll = try await db.pipeline()
      .collection("books")
      .aggregate([CountAll().as("count")])
      .execute()

    // Number of books with nonnull `ratings` field
    let countField = try await db.pipeline()
      .collection("books")
      .aggregate([Field("ratings").count().as("count")])
      .execute()
    // [END count_function]
    print(countAll)
    print(countField)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#count_if
  func countIfFunction() async throws {
    // [START count_if]
    let result = try await db.pipeline()
      .collection("books")
      .aggregate([
        AggregateFunction("count_if", [Field("rating").greaterThan(4)]).as("filteredCount")
      ])
      .execute()
    // [END count_if]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#count_distinct
  func countDistinctFunction() async throws {
    // [START count_distinct]
    let result = try await db.pipeline()
      .collection("books")
      .aggregate([AggregateFunction("count_distinct", [Field("author")]).as("unique_authors")])
      .execute()
    // [END count_distinct]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#sum
  func sumFunction() async throws {
    // [START sum_function]
    let result = try await db.pipeline()
      .collection("cities")
      .aggregate([Field("population").sum().as("totalPopulation")])
      .execute()
    // [END sum_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#avg
  func avgFunction() async throws {
    // [START avg_function]
    let result = try await db.pipeline()
      .collection("cities")
      .aggregate([Field("population").average().as("averagePopulation")])
      .execute()
    // [END avg_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#min
  func minFunction() async throws {
    // [START min_function]
    let result = try await db.pipeline()
      .collection("books")
      .aggregate([Field("price").minimum().as("minimumPrice")])
      .execute()
    // [END min_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/aggregate_functions#max
  func maxFunction() async throws {
    // [START min_function]
    let result = try await db.pipeline()
      .collection("books")
      .aggregate([Field("price").maximum().as("maximumPrice")])
      .execute()
    // [START max_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#add
  func addFunction() async throws {
    // [START add_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("soldBooks").add(Field("unsoldBooks")).as("totalBooks")])
      .execute()
    // [END add_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#subtract
  func subtractFunction() async throws {
    // [START subtract_function]
    let storeCredit = 7
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("price").subtract(Constant(storeCredit)).as("totalCost")])
      .execute()
    // [END subtract_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#multiply
  func multiplyFunction() async throws {
    // [START multiply_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("price").multiply(Field("soldBooks")).as("revenue")])
      .execute()
    // [END multiply_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#divide
  func divideFunction() async throws {
    // [START divide_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("ratings").divide(Field("soldBooks")).as("reviewRate")])
      .execute()
    // [END divide_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#mod
  func modFunction() async throws {
    // [START mod_function]
    let displayCapacity = 1000
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("unsoldBooks").mod(Constant(displayCapacity)).as("warehousedBooks")])
      .execute()
    // [END mod_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#ceil
  func ceilFunction() async throws {
    // [START ceil_function]
    let booksPerShelf = 100
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("unsoldBooks").divide(Constant(booksPerShelf)).ceil().as("requiredShelves")
      ])
      .execute()
    // [END ceil_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#floor
  func floorFunction() async throws {
    // [START floor_function]
    let result = try await db.pipeline()
      .collection("books")
      .addFields([
        Field("wordCount").divide(Field("pages")).floor().as("wordsPerPage")
      ])
      .execute()
    // [END floor_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#round
  func roundFunction() async throws {
    // [START round_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("soldBooks").multiply(Field("price")).round().as("partialRevenue")])
      .aggregate([Field("partialRevenue").sum().as("totalRevenue")])
      .execute()
    // [END round_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#pow
  func powFunction() async throws {
    // [START pow_function]
    let googleplex = CLLocation(latitude: 37.4221, longitude: 122.0853)
    let result = try await db.pipeline()
      .collection("cities")
      .addFields([
        Field("lat").subtract(Constant(googleplex.coordinate.latitude))
          .multiply(111 /* km per degree */)
          .pow(2)
          .as("latitudeDifference"),
        Field("lng").subtract(Constant(googleplex.coordinate.latitude))
          .multiply(111 /* km per degree */)
          .pow(2)
          .as("longitudeDifference")
      ])
      .select([
        Field("latitudeDifference").add(Field("longitudeDifference")).sqrt()
          // Inaccurate for large distances or close to poles
          .as("approximateDistanceToGoogle")
      ])
      .execute()
    // [END pow_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#sqrt
  func sqrtFunction() async throws {
    // [START sqrt_function]
    let googleplex = CLLocation(latitude: 37.4221, longitude: 122.0853)
    let result = try await db.pipeline()
      .collection("cities")
      .addFields([
        Field("lat").subtract(Constant(googleplex.coordinate.latitude))
          .multiply(111 /* km per degree */)
          .pow(2)
          .as("latitudeDifference"),
        Field("lng").subtract(Constant(googleplex.coordinate.latitude))
          .multiply(111 /* km per degree */)
          .pow(2)
          .as("longitudeDifference")
      ])
      .select([
        Field("latitudeDifference").add(Field("longitudeDifference")).sqrt()
          // Inaccurate for large distances or close to poles
          .as("approximateDistanceToGoogle")
      ])
      .execute()
    // [END sqrt_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#exp
  func expFunction() async throws {
    // [START exp_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").exp().as("expRating")])
      .execute()
    // [END exp_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#ln
  func lnFunction() async throws {
    // [START ln_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").ln().as("lnRating")])
      .execute()
    // [END ln_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/arithmetic_functions#log
  func logFunction() async throws {
    // [START log_function]
    // Not supported on iOS
    // END log_function]
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_concat
  func arrayConcat() async throws {
    // [START array_concat]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("genre").arrayConcat([Field("subGenre")]).as("allGenres")])
      .execute()
    // [END array_concat]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_contains
  func arrayContains() async throws {
    // [START array_contains]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("genre").arrayContains(Constant("mystery")).as("isMystery")])
      .execute()
    // [END array_contains]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_contains_all
  func arrayContainsAll() async throws {
    // [START array_contains_all]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("genre")
          .arrayContainsAll([Constant("fantasy"), Constant("adventure")])
          .as("isFantasyAdventure")
      ])
      .execute()
    // [END array_contains_all]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_contains_any
  func arrayContainsAny() async throws {
    // [START array_contains_any]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("genre")
          .arrayContainsAny([Constant("fantasy"), Constant("nonfiction")])
          .as("isMysteryOrFantasy")
      ])
      .execute()
    // [END array_contains_any]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_length
  func arrayLength() async throws {
    // [START array_length]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("genre").arrayLength().as("genreCount")])
      .execute()
    // [END array_length]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/array_functions#array_reverse
  func arrayReverse() async throws {
    // [START array_reverse]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("genre").arrayReverse().as("reversedGenres")])
      .execute()
    // [END array_reverse]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#eq
  func equalFunction() async throws {
    // [START equal_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").equal(5).as("hasPerfectRating")])
      .execute()
    // [END equal_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#gt
  func greaterThanFunction() async throws {
    // [START greater_than]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").greaterThan(4).as("hasHighRating")])
      .execute()
    // [END greater_than]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#gte
  func greaterThanOrEqualToFunction() async throws {
    // [START greater_or_equal]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("published").greaterThanOrEqual(1900).as("publishedIn20thCentury")])
      .execute()
    // [END greater_or_equal]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#lt
  func lessThanFunction() async throws {
    // [START less_than]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("published").lessThan(1923).as("isPublicDomainProbably")])
      .execute()
    // [END less_than]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#lte
  func lessThanOrEqualToFunction() async throws {
    // START less_or_equal]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").lessThanOrEqual(2).as("hasBadRating")])
      .execute()
    // [END less_or_equal]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/comparison_functions#neq
  func notEqualFunction() async throws {
    // [START not_equal]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("title").notEqual("1984").as("not1984")])
      .execute()
    // [END not_equal]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/debugging_functions#exists
  func existsFunction() async throws {
    // [START exists_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([Field("rating").exists().as("hasRating")])
      .execute()
    // [END exists_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#and
  func andFunction() async throws {
    // [START and_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        (Field("rating").greaterThan(4) && Field("price").lessThan(10))
          .as("under10Recommendation")
      ])
      .execute()
    // [END and_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#or
  func orFunction() async throws {
    // [START or_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        (Field("genre").equal("Fantasy") || Field("tags").arrayContains("adventure"))
          .as("matchesSearchFilters")
      ])
      .execute()
    // [END or_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#xor
  func xorFunction() async throws {
    // [START xor_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        (Field("tags").arrayContains("magic") ^ Field("tags").arrayContains("nonfiction"))
          .as("matchesSearchFilters")
      ])
      .execute()
    // [END xor_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#not
  func notFunction() async throws {
    // [START not_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        (!Field("tags").arrayContains("nonfiction"))
          .as("isFiction")
      ])
      .execute()
    // [END not_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#cond
  func condFunction() async throws {
    // [START cond_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("tags").arrayConcat([
          ConditionalExpression(
            Field("pages").greaterThan(100),
            then: Constant("longRead"),
            else: Constant("shortRead")
          )
        ]).as("extendedTags")
      ])
      .execute()
    // [END cond_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#eq_any
  func equalAnyFunction() async throws {
    // [START eq_any]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("genre").equalAny(["Science Fiction", "Psychological Thriller"])
          .as("matchesGenreFilters")
      ])
      .execute()
    // [END eq_any]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#not_eq_any
  func notEqualAnyFunction() async throws {
    // [START not_eq_any]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("author").notEqualAny(["George Orwell", "F. Scott Fitzgerald"])
          .as("byExcludedAuthors")
      ])
      .execute()
    // [END not_eq_any]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#is_nan
  func isNaNFunction() async throws {
    // [START is_nan]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("rating").isNan().as("hasInvalidRating")
      ])
      .execute()
    // [END is_nan]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#is_not_nan
  func isNotNaNFunction() async throws {
    // [START is_not_nan]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("rating").isNotNan().as("hasValidRating")
      ])
      .execute()
    // [END is_not_nan]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#max
  func maxLogicalFunction() async throws {
    // [START max_logical_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("rating").logicalMaximum([1]).as("flooredRating")
      ])
      .execute()
    // [END max_logical_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/logical_functions#min
  func minLogicalFunction() async throws {
    // [START min_logical_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("rating").logicalMinimum([5]).as("cappedRating")
      ])
      .execute()
    // [END min_logical_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/map_functions#map_get
  func mapGetFunction() async throws {
    // [START map_get]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("awards").mapGet("pulitzer").as("hasPulitzerAward")
      ])
      .execute()
    // [END map_get]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#byte_length
  func byteLengthFunction() async throws {
    // [START byte_length]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("title").byteLength().as("titleByteLength")
      ])
      .execute()
    // [END byte_length]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#char_length
  func charLengthFunction() async throws {
    // [START char_length]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("title").charLength().as("titleCharLength")
      ])
      .execute()
    // [END char_length]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#starts_with
  func startsWithFunction() async throws {
    // [START starts_with]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("title").startsWith("The")
          .as("needsSpecialAlphabeticalSort")
      ])
      .execute()
    // [END starts_with]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#ends_with
  func endsWithFunction() async throws {
    let result = try await db.pipeline()
      .collection("inventory/devices/laptops")
      .select([
        Field("name").endsWith("16 inch")
          .as("16InLaptops")
      ])
      .execute()
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#like
  func likeFunction() async throws {
    // [START like]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("genre").like("%Fiction")
          .as("anyFiction")
      ])
      .execute()
    // [END like]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#regex_contains
  func regexContainsFunction() async throws {
    // [START regex_contains]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("title").regexContains("Firestore (Enterprise|Standard)")
          .as("isFirestoreRelated")
      ])
      .execute()
    // [END regex_contains]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#regex_match
  func regexMatchFunction() async throws {
    // [START regex_match]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("title").regexMatch("Firestore (Enterprise|Standard)")
          .as("isFirestoreExactly")
      ])
      .execute()
    // [END regex_match]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_concat
  func strConcatFunction() async throws {
    // [START str_concat]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("title").concat([" by ", Field("author")])
          .as("fullyQualifiedTitle")
      ])
      .execute()
    // [END str_concat]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_contains
  func strContainsFunction() async throws {
    // [START string_contains]
    let result = try await db.pipeline()
      .collection("articles")
      .select([
        Field("body").stringContains("Firestore")
          .as("isFirestoreRelated")
      ])
      .execute()
    // [END string_contains]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#to_upper
  func toUpperFunction() async throws {
    // [START to_upper]
    let result = try await db.pipeline()
      .collection("authors")
      .select([
        Field("name").toUpper()
          .as("uppercaseName")
      ])
      .execute()
    // [END to_upper]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#to_lower
  func toLowerFunction() async throws {
    // [START to_lower]
    let result = try await db.pipeline()
      .collection("authors")
      .select([
        Field("genre").toLower().equal("fantasy")
          .as("isFantasy")
      ])
      .execute()
    // [END to_lower]
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#substr
  func substrFunction() async throws {
    // [START substr_function]
    let result = try await db.pipeline()
      .collection("books")
      .where(Field("title").startsWith("The "))
      .select([
        Field("title").substring(position: 4)
          .as("titleWithoutLeadingThe")
      ])
      .execute()
    // [END substr_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_reverse
  func strReverseFunction() async throws {
    // [START str_reverse]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("name").reverse().as("reversedName")
      ])
      .execute()
    // [END str_reverse]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_trim
  func strTrimFunction() async throws {
    // [START trim_function]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("name").trim().as("whitespaceTrimmedName")
      ])
      .execute()
    // [END trim_function]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_replace
  func strReplaceFunction() async throws {
    // not yet supported until GA
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/string_functions#str_split
  func strSplitFunction() async throws {
    // not yet supported until GA
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#unix_micros_to_timestamp
  func unixMicrosToTimestampFunction() async throws {
    // [START unix_micros_timestamp]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("createdAtMicros").unixMicrosToTimestamp().as("createdAtString")
      ])
      .execute()
    // [END unix_micros_timestamp]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#unix_millis_to_timestamp
  func unixMillisToTimestampFunction() async throws {
    // [START unix_millis_timestamp]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("createdAtMillis").unixMillisToTimestamp().as("createdAtString")
      ])
      .execute()
    // [END unix_millis_timestamp]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#unix_seconds_to_timestamp
  func unixSecondsToTimestampFunction() async throws {
    // [START unix_seconds_timestamp]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("createdAtSeconds").unixSecondsToTimestamp().as("createdAtString")
      ])
      .execute()
    // [END unix_seconds_timestamp]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#timestamp_add
  func timestampAddFunction() async throws {
    // [START timestamp_add]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("createdAt").timestampAdd(3653, .day).as("expiresAt")
      ])
      .execute()
    // [END timestamp_add]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#timestamp_sub
  func timestampSubFunction() async throws {
    // [START timestamp_sub]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("expiresAt").timestampSubtract(14, .day).as("sendWarningTimestamp")
      ])
      .execute()
    // [END timestamp_sub]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#timestamp_to_unix_micros
  func timestampToUnixMicrosFunction() async throws {
    // [START timestamp_unix_micros]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("dateString").timestampToUnixMicros().as("unixMicros")
      ])
      .execute()
    // [END timestamp_unix_micros]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#timestamp_to_unix_millis
  func timestampToUnixMillisFunction() async throws {
    // [START timestamp_unix_millis]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("dateString").timestampToUnixMillis().as("unixMillis")
      ])
      .execute()
    // [END timestamp_unix_millis]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/timestamp_functions#timestamp_to_unix_seconds
  func timestampToUnixSecondsFunction() async throws {
    // [START timestamp_unix_seconds]
    let result = try await db.pipeline()
      .collection("documents")
      .select([
        Field("dateString").timestampToUnixSeconds().as("unixSeconds")
      ])
      .execute()
    // [END timestamp_unix_seconds]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/vector_functions#cosine_distance
  func cosineDistanceFunction() async throws {
    // [START cosine_distance]
    let sampleVector = [0.0, 1, 2, 3, 4, 5]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("embedding").cosineDistance(sampleVector).as("cosineDistance")
      ])
      .execute()
    // [END cosine_distance]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/vector_functions#dot_product
  func dotProductFunction() async throws {
    // [START dot_product]
    let sampleVector = [0.0, 1, 2, 3, 4, 5]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("embedding").dotProduct(sampleVector).as("dotProduct")
      ])
      .execute()
    // [END dot_product]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/vector_functions#euclidean_distance
  func euclideanDistanceFunction() async throws {
    // [START euclidean_distance]
    let sampleVector = [0.0, 1, 2, 3, 4, 5]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("embedding").euclideanDistance(sampleVector).as("euclideanDistance")
      ])
      .execute()
    // [END euclidean_distance]
    print(result)
  }

  // https://cloud.google.com/firestore/docs/pipeline/functions/vector_functions#vector_length
  func vectorLengthFunction() async throws {
    // [START vector_length]
    let result = try await db.pipeline()
      .collection("books")
      .select([
        Field("embedding").vectorLength().as("vectorLength")
      ])
      .execute()
    // [END vector_length]
    print(result)
  }
}
