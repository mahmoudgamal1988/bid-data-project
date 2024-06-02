import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

# Initialize Spark session
spark = SparkSession.builder.appName('IrisClassifier').getOrCreate()

# Load Iris dataset from Scikit-learn
iris = load_iris()
data = pd.DataFrame(data=iris.data, columns=iris.feature_names)
data['target'] = iris.target

# Split the data into training and testing sets
train_data, test_data = train_test_split(data, test_size=0.2, random_state=42)

# Convert to Spark DataFrame
train_df = spark.createDataFrame(train_data)
test_df = spark.createDataFrame(test_data)

# Prepare features
assembler = VectorAssembler(inputCols=iris.feature_names, outputCol='features')
train_df = assembler.transform(train_df)
test_df = assembler.transform(test_df)

# Initialize RandomForestClassifier
rf = RandomForestClassifier(labelCol='target', featuresCol='features', numTrees=10)

# Train the model
model = rf.fit(train_df)

# Make predictions
predictions = model.transform(test_df)

# Evaluate the model
evaluator = MulticlassClassificationEvaluator(labelCol='target', predictionCol='prediction', metricName='accuracy')
accuracy = evaluator.evaluate(predictions)
print(f'Test Accuracy: {accuracy}')

# Stop Spark session
spark.stop()
