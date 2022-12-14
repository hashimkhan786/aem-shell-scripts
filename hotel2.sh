#!/bin/bash
set -e
Total=0
echo "Hi Sir, welecome to in our hotel"
echo "The available food items are"
echo " 1 - idli "
echo " 2 - vada "
echo " 3 - masala doasa "
echo " 4 - onion dosa "
echo " 5 - samosa "
echo " 6 - vadapav "
echo " 7 - south meals "
echo " 8 - north meals "
echo " 9 - quiting "
echo -n " Enter your rate choice [1-8]: "
while :
do
echo -n " Enter your rate choice [1-8]: "
read rates
case $rates in 
        1)
                echo  I want idli
echo -e " enter the qty "
read qty
rate=10
;;

        2)
                echo I want vada
echo -e " enter the qty "
read qty
rate=15
;;
        3)
                echo I want masala dosa
echo -e " enter the qty "
read qty      
rate=30
;;

        4)
                echo  I want onion dasa
echo -e " enter the qty "
read qty 
rate=35
;;
        5)
                echo I want samosa
echo -e " enter the qty "
read qty 
rate=20
;;
        6)
                echo I want vadapav
echo -e " enter the qty "
read qty 
rate=35
;;
        7)
                echo I want south meals
echo -e " enter the qty "
read qty
rate=70
;;
        8)
                echo I want north meals
echo -e " enter the qty "
read qty
rate=120
;;
	9)	echo your order will be within 5 mins plz wait sir
     		break
		;;
esac
cal=`expr $qty \* $rate`
Total=`expr $cal + $Total`
done

echo "Total Bill:$Total"
echo "Thank you sir, Visit Again"
