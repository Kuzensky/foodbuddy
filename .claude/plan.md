# FoodBuddy App Feature Outline

## Overview

FoodBuddy is a social dining platform where users can **discover and join meal sessions**, **create their own sessions**, **connect with others**, and **share food experiences**. The app allows users to filter restaurants, manage invitations, and interact through posts and messaging. The interface uses a **gray-and-white color scheme** with **proper typography**, and selective icons have color for emphasis.

**Core Workflow:**

1. **Discover:** Users can browse existing meal sessions or create their own, setting preferences for who can join.
2. **Matches:** Users see who joined their sessions and can accept or reject participants. Messaging is available for planning meals.
3. **Social:** Users share posts, view feeds, and interact with others through likes, comments, and messages.
4. **Search:** Users can search for other users or posts using a grid layout and follow/add them.
5. **Profile:** Users can view and edit their profile, see their posts, meetups, and reviews.

The app focuses on simplicity, intuitive navigation, and social connectivity around food experiences.

---

## 1. Discover

* **Top Bar:**

  * Right: `FoodBuddy` logo/text
  * Left: Filter icon → opens a new screen showing a **map of restaurants** (API-integrated).

    * Bottom of map shows filter options (cuisine, price, distance, etc.).

* **Toggle Button:** `Discover` | `Create`

  * **Discover Section:**

    * Displays **sessions created by other users** in containers.
    * Users can **pass** or **join** each session.
  * **Create Section:**

    * Users can **create a session** for others to join.
    * **Edit Preferences:** When creating a session, users can **set preferences on who can join** (e.g., age, interests, food preferences).

* **Color Scheme & Typography:**

  * Main colors: **Gray and White**
  * Typography: **Proper font hierarchy for headings, body, and labels**
  * Only certain icons (like create post, message, and filter) can have color highlights.

---

## 2. Matches

* Shows users who **joined your sessions**.
* **Accept/Reject:** Platform to approve or decline users joining your session.
* **User Container:**

  * Tap → animation shows **basic information**.
  * **Message Button:** Navigates to **message screen** to plan meals.

---

## 3. Social

* **Feed:**

  * Users can **share posts of their meals**.
  * Scrollable feed to view posts from others.

* **Top Bar:**

  * **Create Post Icon** → add a new post.
  * **Message Icon** → opens messaging:

    * **Pending requests**
    * **Planning sessions**
    * **Conversations with friends**

* **Interactions:**

  * Like, comment, share posts
  * Search users or posts (see Section 4)

---

## 4. Search

* **Search Section:**

  * Tap **search navigation bar** → shows a **grid of post pictures**.
  * Top of grid → **search bar** to search users.
  * Tap a user → navigate to **profile** → option to follow or message.
* **Add Users:** Users can **send friend requests** or follow others from search results.

---

## 5. Profile

* **Top Bar:**

  * Right: `Username`
  * Left: **Settings icon (3 lines)** → logout, preferences

* **User Profile Info:**

  * **Profile Picture:** Displayed on the left side of the profile info
  * Right side: `Name (Verified) | Posts | Followers | Following` → **2 columns, 1 row**
  * Bio → editable
  * Food preference tags → editable

* **Edit Profile:**

  * Update profile information, bio, food preferences

* **Sections Below Profile:**

  * **Posts:** Grid layout, gray container placeholder for pictures
  * **Meetups:** Shows upcoming, completed, or planning sessions (user-only)
  * **Reviews:** Shows reviews from meals with other users

    * Users can **edit which reviews are shown**

---

### ✅ Key Features Added for Social/Search (3 & 4):

* Feed of posts
* Create post button at top
* Messaging system with pending, planning, and conversations
* Search posts and users using a grid layout
* Follow/add users from search results
* **Gray and White color scheme** with proper typography
* Selective colored icons only for highlights
