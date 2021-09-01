#!/bin/bash

returnMonth () {

    export numMonth=$1
    
    case "$numMonth" in
	'01' )
	    export currentMonth='jan' ;
	    ;;
	'02' )
	    export currentMonth='feb' ;
	    ;;
	'03' )
	    export currentMonth='mar' ;
	    ;;
	'04' )
	export currentMonth='apr' ;
	;;
	'05' )
	export currentMonth='may' ;
	;;
	'06' )
	    export currentMonth='jun' ;
	    ;;
	'07' )
	    export currentMonth='jul' ;
	    ;;
	'08' )
	    export currentMonth='aug' ;
	    ;;
	'09' )
	    export currentMonth='sep' ;
	    ;;
	'10' )
	    export currentMonth='oct' ;
	    ;;
	'11' )
	    export currentMonth='nov' ;
	    ;;
	'12' )
	    export currentMonth='dec' ;
	    ;;
	
	* )
	    export currentMonth='xxx' ;
	    ;;
    esac
    
    if [ "$currentMonth" = "xxx" ]; then
	echo "Month not recognized"
	exit -1
    fi
    
    eval "$2=$currentMonth"
}


