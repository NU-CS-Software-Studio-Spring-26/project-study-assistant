# Study Assistant
 
> A smarter calendar for students — syncs Canvas assignments with exact due times, custom reminders, and study group coordination.
 

 
## The Problem
 
Canvas has a built-in schedule view, but it only shows *dates* — not the specific time an assignment is due. Students are left piecing together deadlines from individual course pages, missing late-night cutoffs, and juggling multiple classes with no unified view.
 

 
## What Study Assistant Does
 
Study Assistant pulls your Canvas assignments and due dates into a single, time-accurate calendar you actually want to use.
 
### MVP (v1.0)
 
- **Authenticated Canvas integration** via the Canvas LMS REST API
- **Unified calendar view** displaying all assignments across all enrolled courses
- **Exact due times** — not just dates
- **Custom notifications** — set reminders however far in advance you want
- **Multi-course support** — everything in one place
 
### Roadmap
 
| Feature | Status |
|---|---|
| Canvas OAuth login
| Unified assignment calendar 
| Due-time display 
| Custom push/email notifications
| Study group formation & discovery
| Shared class calendars 
| Group chat & coordination tools
| AI-powered study assistant 
 
## Getting Started
 
### Prerequisites
 
- A Canvas account with API access enabled
- Node.js v18+ (or your runtime of choice)
- A Canvas API token ([how to generate one](https://community.canvaslms.com/t5/Student-Guide/How-do-I-manage-API-access-tokens-as-a-student/ta-p/273))
 

 
### Configuration
 
Create a `.env` file in the root directory:
 
```env
CANVAS_API_TOKEN=your_token_here
CANVAS_BASE_URL=https://your-institution.instructure.com
```

 
## Architecture

canvassync/
├── src/
│   ├── api/          # Canvas API client
│   ├── calendar/     # Calendar sync logic
│   ├── notifications/# Notification scheduler
│   └── ui/           # Frontend components
├── .env.example
└── README.md

 
## Contributing

Contributors: 

Andrew, Jace, Natalie, Ken
 
Heroku Link:
(heroku open)

https://calm-river-85968-8e2e9aa9b5a5.herokuapp.com/