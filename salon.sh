#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~ Welcome to My Salon ~~\n"

# Function to display services
display_services() {
  echo -e "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to book appointment
book_appointment() {
  # Prompt for service ID
  echo -e "\nPlease select a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED

  # Check if the service ID is valid
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service ID. Please select a valid service."
    display_services
    book_appointment
  else
    # Prompt for phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if the customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      # Prompt for customer name
      echo -e "\nIt looks like you're a new customer. Please enter your name:"
      read CUSTOMER_NAME
      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi

    # Prompt for appointment time
    echo -e "\nEnter the time you would like your appointment:"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # Confirm appointment
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Display services and book appointment
display_services
book_appointment
