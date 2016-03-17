# MemeMe.
## Second project of Udacity iOS Nanodegree

*NB! The project is written with Swift 1.2 and won't compile with Swift 2.2*

MemeMe is a meme-generating app that enables a user to attach a caption to a picture from their phone.
After adding text to an image chosen from the Photo Album or Camera, the user can share it with friends.

**Meme Editor View**

The Meme Editor View consists of an image view overlaid by two text fields, one near the topand one
near the bottom of the image. This view has a bottom toolbar with two buttons: one for the camera and
one for the photo album. The top navigation bar has a share button on the left displaying Apple’s stock
share icon and a “Cancel” button on the right.


**Sent Memes View**

The sent memes view displays recently sent memes. It has a bottom toolbar with tabs that allow the user
to toggle between viewing sent memes in a table and viewing them in a grid. The top navigation bar has a
title that reads “Sent Memes” and an add button in the right corner displaying Apple’s stock “Add” icon.
If the user taps the “table” tab on the left of the bottom toolbar, sent memes are displayed in a table.
If the user taps on the “collection” tab on the right of the bottom toolbar, sent memes are displayed in
a grid. Selecting a meme from the table or collection presents the Meme Detail View. Pressing the “add”
button brings up the Meme Editor View.

**Meme Detail View**

The Meme Detail View displays the selected meme in an image view in the center of the page with the meme’s
original aspect ratio. The detail view has a back arrow in the top left corner. To the right of the arrow
reads the title of the previous view, “Sent Memes.”

**User Flow**

When the user first launches the app the Sent Memes View will appear. It will be the root view of the
navigation stack. When the user taps the + button in the top right corner the app should push the
Meme Editor View on top of the Sent Memes View.
In the Meme Editor View, when the user clicks on the “Album” button, an Image Picker is presented,
making it possible to choose an image from the Photo Album. If there is a camera available on the device,
pressing the camera button launches the camera, and a newly snapped photo can be chosen for the meme.
If a camera is not available on the device, the camera button is disabled.
After an image is chosen, the image picker is dismissed, allowing text to be entered into the top and bottom
text fields of the editor. When a user clicks inside one of the text fields, the default text disappears and
the keyboard slides up. When the user finishes entering text and presses return, the keyboard is dismissed
and the new meme is displayed.
When the user presses the share button, Apple’s stock Activity View appears, displaying several options
for sharing the meme. After an option is chosen, the Activity View is dismissed and the Sent Memes View appears.
The Sent Memes View also appears upon pressing the “Cancel” button.
Selecting a meme from the table or collection presents the Meme Detail View. Clicking on the  back arrow
of the Meme Detail View presents the previous Sent Memes View, either the table or collection.  
