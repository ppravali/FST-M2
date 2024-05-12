-- Define input paths for your three text files
input1 = 'hdfs:///user/Pravallika/file1.txt';
input2 = 'hdfs:///user/Pravallika/file2.txt';
input3 = 'hdfs:///user/Pravallika/file3.txt';

-- Load data from the three files
data = LOAD '$input1,$input2,$input3' USING PigStorage(' ') AS (line:chararray);

-- Merge all lines into a single relation
merged_data = GROUP data ALL;
merged_lines = FOREACH merged_data GENERATE FLATTEN(data.line) AS line;

-- Count the number of lines and words
line_count = FOREACH merged_lines GENERATE COUNT(merged_lines) AS num_lines;
word_count = FOREACH merged_lines GENERATE SUM(TOKENIZE(line)) AS num_words;

-- Calculate rank for each file
ranked_lines = RANK line_count;
ranked_words = RANK word_count;

-- Join the ranks with the original data
joined_data = JOIN ranked_lines BY $0, ranked_words BY $0;
final_results = FOREACH joined_data GENERATE $1 AS file_rank, line_count, word_count;

-- Order the results by rank
ordered_results = ORDER final_results BY file_rank;

-- Store the results in an output file
STORE ordered_results INTO '/user/Pravallika/output/results' USING PigStorage('\t');