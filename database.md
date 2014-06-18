# Database Organizazion

- **User**
  - Username, emails
  - **type**: 'student', 'teacher' or 'admin'
  - *Student*
    - Class ID (classes decide, this is just a cache)
  - *Teacher*
    - Classes ID (the classes decide, this is just a cache)

- **Class**
  - Year, Course, Section
  - **Student ID list**
  - **Teacher ID list**
    - a *folder* for each teacher
     - **Posts ID list**, **Homeworks ID list** and **Tests ID list**
