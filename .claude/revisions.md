# App UI & Features - Claude Code Prompt (Updated)

## Global Changes

* Currency symbol changed from `$` to `₱`.

## 1. Discover Section

### Layout & Features

* **AppBar Behavior:** Changes color when scrolling below it.
* **Create Session Toggle:** Allows viewing **sessions you created** alongside joinable sessions.
* **Session Card Design:** Modern and minimalist; smaller containers; description field with 3-line height; placeholder text "Description" animates to top while typing inside the text box.
* **Full-Screen Map:**

  * Fills entire screen.
  * Shows nearby restaurants with interactive pins.
  * Pins color-coded by cuisine type or popularity.
  * Zoomable and draggable; optional clustering in dense areas.
* **Sliding Bottom Panel:**

  * Collapsed: small bar with selected restaurant name.
  * Expanded: full session creation options.
  * Contents:

    * Restaurant Info: Name, rating, address, optional thumbnail.
    * Description Field: 3-line height with animated placeholder.
    * Session Details: Date & Time Picker, Number of Participants (slider/stepper), Price Range Selector (slider/dropdown), Food Preferences / Tags (multi-select).
    * Map Radius Selector (optional): visual circle overlay; adjustable with pinch/drag.
    * Create / Preview Button: fixed at bottom.
* **Additional Interactions:**

  * Tap map pin → updates bottom panel.
  * Swipe down panel → collapse.
  * Tap outside panel → explore map.
  * Existing sessions nearby appear as small icons.
* **Filtering Features:**

  * Filter by cuisine, popularity, price range, tags.
  * Controls in bottom panel or floating buttons.
  * Applying filters updates visible pins dynamically.

### Session Management

* Section titled **"Your Sessions"**.
* Shows list/card view of **active sessions you created**.
* Session Card Includes:

  * Restaurant name, Date & Time, Number of participants / max capacity, Optional thumbnail.
* Actions:

  * **Cancel Session:** confirmation popup.
  * **Invite / Share:** modal to select friends and add optional message; sends in-app notification or message.

## 2. Matches Section

* Toggle between **Active Sessions | Pending Requests** like in Discover.
* Displays respective sessions accordingly.

## 3. Social Section

* **Posts:** Dedicated new screen for creating posts.
* **Messages:** Dedicated new screen to see friend messages; only visible if both users follow each other but you can also view the messages of the poeple your palning to go on a lunch or dner with but with a toglle button also at the top 

* **Search** 
* When in search screen all the post that will be tapped will look like a scrolling section like social but has a back button at the top-left when tapped will go to seacrch again 
* make the seacrch container smaller and fix the design into a modern one 


**Profile**
* Make the username on the top_left a bit bigger
* for the Food prefereneces remove the edit all edit will be seen in edit profile 
* Make the edit Profile Work and make a new screen for it 

Make the loading into a skeleton loading
add a minimal animations on all buttons 


