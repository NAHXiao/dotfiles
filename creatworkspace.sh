WORKSPACE="$HOME/workspace"
mkdir -p $WORKSPACE $WORKSPACE/learn $WORKSPACE/leetcode
for i in 'c++' 'java' 'python' 'rust' ;do
mkdir -p $WORKSPACE/$i $WORKSPACE/$i/learn $WORKSPACE/$i/leetcode
ln -s $WORKSPACE/$i/leetcode $WORKSPACE/leetcode/$i
done
