# See the number of commits where a particular files has been modified
git log --format=oneline -- app/models/user.rb | wc -l

# Top-10 files according to churn factor
find app/models -name "*.rb" | while read file; do echo $file `git log --format=oneline -- $file | wc -l`; done | sort -k 2 -nr | head

# Flog example usage (https://github.com/seattlerb/flog)
flog -s app/models/user.rb
