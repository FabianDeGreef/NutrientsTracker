# NutrientsTracker
Mobile Development Project

## NutrientsTracker wiki!

## The App Features

_**User Authentication**_

The user can register a new email and password
The user can login with an existing email and password
The email and password are validated in real-time the text fields and properties changes to prevent invalid values.
If the user was already signed in and the app state changes (suspend, closed or shutdown) the user can continue without logging in again
The user can logout from the Date Screen and Day Setup screen

_**Day Total Management**_

The user can pick a date to create a new Day Total, Every Day Total is unique by the date
The user can see the existing Day Totals inside the table by there date and consumed product count
The user can select and load an existing Day Total from the table which is unique per user
The user can remove a day Total from the table

_**Adding Products and Display Products**_

The user can add and save a new product. The product text fields and properties are in real-time validated when invalid default values will be inserted
The user can add a product image by using the camera or the library
The user can reset the product form to its default value

_**Querying Existing Products**_

The user can search by entering a name to find a matching product inside the database
The user can select, view or remove a product
When the user views a product the product details are displayed
When the user removes a product it will be removed from the screen and database
The user can fill in the consumed weight to calculate the product values from 100 g to the correct values this is now a consumed product

_**Mange The Consumed Products and Nutrients**_

The user can add the consumed products to the day Total
The user can display the Day Total with all the consumed products inside the table with there name and consumed weight
The user can view a consumed product details by selecting a cell
The user can remove a consumed product from the Day Total
The Day Total will re calculate the nutrient values when a consumed product is removed from it
