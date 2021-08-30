# WordCounter

Configurable CLI to count words in a reference col of a CSV file

## Getting Started

Clone the repo and install dependencies:

```zsh
$ git clone https://github.com/luke-hawk/word_counter.git
$ cd word_counter
$ bundle
```

Run the CLI

```bash
$ ruby word_counter.rb
# "Where is your CSV file located?" ./example
# "In which file do you want to count words?" ./example/imdb-1000.csv
# "What separator does your CSV use?" ,
# "In which column would you like to count words?" Description
# "How many occurences do you require to count a word?" 2
# "Do you want to copy a value of a certain column to the resulting CSV? (e.g. an id)" Yes
# "Which column do you want to use as id?" Rank
# "Where shall the result be saved?" ./example
```

### Exclude words from counting
In order to exclude certain words from counting just add them to the `exclude.txt` file on the root of the project.