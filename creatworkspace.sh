WORKSPACE="$HOME/workspace/"
for i in '0.static' '1.homework' '2.lab' '3.project' '5.leetcode' '6.platform' '7.repos' ;do
    mkdir -p $WORKSPACE/$i
done
WORKSPACE="$HOME/workspace/4.language"
for i in 'c++' 'java' 'python' 'rust' ;do
    mkdir -p $WORKSPACE/$i $WORKSPACE/$i/learn $WORKSPACE/$i/leetcode
done
