# Install
OTSRenderer is "ready to go", just download the "Home" folder and all of its content to your destination folder and run it by double clicking on it.

# Setup a run
The setup process can seem a bit complicated but we're here to explain all in detail, starting with the setting options on the first screen, from the top to the bottom.

### Home tab
1. **Input file**: with this option you choose the file containing the informations of the players to be processed. It has to be a pure text file in CSV (comma separated values) format, we will come back to it later.
2. **Manually add inputs**: in this panel you can add any player informations by typing them into the appropriate fields and then clicking the "Add" button; you must fill at least the fields marked with "\*" for a player to be a valid input.
3. **Manually added inputs**: in this list you will see your manual inputs appear after you click the afromentioned "Add" button; you can also remove one entry from the list by selecting it and clicking the "Remove" button. Clicking the "Clear All" button removes all the entries.
4. **Color palette**: this dropdown list lets you choose the color palette for the HTML and PNG rendering.
5. **Second language on OTS**: with this option you can choose what will be the second language for all of the rendered open teamsheet PDFs. If your choice coincides with the default language (English), the open teamsheet PDFs will be rendered in one language only.
6. **Output folder**: the folder in which the output files will be places, entirely optional. If none is specified, the application will create an "Output" folder under the "Home" folder and will use that as the "Output folder".
7. **Create Images**: the button that performs all the renderings.

### Configuration tab
1. **CSV File input column names**: in this panel you have to specify the column names in the selected input CSV file (on point 1 of the *Home tab* list) as they are in the header (first row) of the file.
2. **Other CSV File input configurations**: in this panel you have to specify what the date format used in the file is (for the birth date of the players) and what the CSV delimiter is.
3. **Outputs**: you can choose what outputs you want the application to render.
4. **Resources path**: the root folder containing all of the program resources (data, sprites, ...). Unless you are using different instances of this or other applications located on different paths but relying to the same resources, you should avoid changing the default value.
5. **Enable preview**: enables/disables the preview section.
6. **Reload Language configuration**: if you make an edit on the [languages file](/Home/languages.csv) while the application is already running and you want it to be loaded instantly, this button lets you do it without needing to exit and re-open the application.

### Preview
The preview section is just a monitor to the pokepaste that is being currently rendered. It's nice to have a immediate response on the rendering but it is in no means necessary.
Disabling it will make the rendering faster.

# Notes
Since the form of this application is "quite tall" and that Windows likes to set the scale option on 125% or 150% automatically on laptops, you can experience some issues with the dimensions of the form:
I suggest you work with it with the preview disabled, to avoid any trouble with the app window being too big. Changing your Windows scale setting to 100% is also an option.

# Customize OTSRenderer
The only customizable feature right now is the possibility to add/edit the color palettes, which are read dynamically from the CSS files under the **Resources path** (point 4 of the *Configuration tab* list).
To add or edit a palette you should add or edit those CSS files (named **{color name}_palette.css**) directly and create an empty PNG template with your colors of choice in the same folder (as the files **{color name}_template.png**).
Adding the CSS will make your palette to appear on the list and will reflect on the HTML rendering while the PNG template is needed for the PNG rendering (if it's absent, the PNG rendering will break).
If you don't need the PNG rendering you can avoid creating the empty PNG template.