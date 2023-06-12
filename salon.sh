#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

display_menu() {
    if [[ $1 ]] 
    then
        echo -e "\n$1"
    fi
# show the list of services and read the client selection
    SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  
    echo "$SERVICES" | while read service_id bar name
    do
    echo "$service_id) $name"
    done
    read SERVICE_ID_SELECTED  
}

menu() {
  display_menu
if [[ -z $SERVICE_ID_SELECTED || ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  display_menu "I could not find that service. What would you like today?"
fi
# check if service exists, otherwise send back to display_menu
SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_AVAILABLE ]]
  then
  display_menu "I could not find that service. What would you like today?"
fi
# service exists so get phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# check if the customer is already in the database
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
# if it's not there then get their name
if  [[ -z $CUSTOMER_ID ]]
  then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert the customer
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
fi
# Get the time for the scheduled service
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME_ABV=$(echo $SERVICE_NAME | sed 's/ |/"/')
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_NAME_ABV=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
echo -e "\nWhat time do you want your $SERVICE_NAME_ABV, $CUSTOMER_NAME_ABV?"
read SERVICE_TIME
# Add the appointment to the database
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
SERVICE_TIME_ADD=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
echo -e "\nI have put you down for a $SERVICE_NAME_ABV at $SERVICE_TIME, $CUSTOMER_NAME_ABV." 
}
menu

