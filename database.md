# Database Organizazion

- **User**
  - Username, email
  - Full name
  - Registration date and last time logged in date
  - **type**: 'student', 'teacher' or 'admin'

- **Class**
  - Year, Course, Section
  - **Student ID list**
  - **Teacher ID list**

- **Test**
  - Teacher (creator) id

- **Post**
  - creation date
  - userId of the owner
  - parent id (if it doesn't exist then this is not a reply post)
  - title
  - post text (character limit?)
  - Attached files list
  - due date (if this is a Homework)
  - Read and Edit/Delete permissions (this needs planning)
  - display:
    - classes: classes where the post is displayed
    - users: user pages where the post is displayed
    - pages: other pages where the post is displayed. Example: ['admin','homepage']


- **File**
  - name
  - file data
