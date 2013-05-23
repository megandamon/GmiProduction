echo "Fake submissions script"

#CURRENT_PATH=$(dirname $(readlink -f $0))
CURRENT_PATH=$(dirname $0)
echo $CURRENT_PATH
chmod -R +x $CURRENT_PATH/*
