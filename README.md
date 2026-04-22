# Rewild 📅
 
> A smarter calendar for students — syncs Canvas assignments with exact due times, custom reminders, and study group coordination.
 
---
 
## The Problem
 
Canvas has a built-in schedule view, but it only shows *dates* — not the specific time an assignment is due. Students are left piecing together deadlines from individual course pages, missing late-night cutoffs, and juggling multiple classes with no unified view.
 
---
 
## What Rewild Does
 
Rewild pulls your Canvas assignments and due dates into a single, time-accurate calendar you actually want to use.
 
### ✅ MVP (v1.0)
 
- **Authenticated Canvas integration** via the Canvas LMS REST API
- **Unified calendar view** displaying all assignments across all enrolled courses
- **Exact due times** — not just dates
- **Custom notifications** — set reminders however far in advance you want
- **Multi-course support** — everything in one place
 
### 🚀 Roadmap
 
| Feature | Status |
|---|---|
| Canvas OAuth login | MVP |
| Unified assignment calendar | MVP |
| Due-time display | MVP |
| Custom push/email notifications | MVP |
| Study group formation & discovery | Planned |
| Shared class calendars | Planned |
| Group chat & coordination tools | Planned |
| AI-powered study assistant | Planned |
 
---
 
## Getting Started
 
### Prerequisites
 
- A Canvas account with API access enabled
- Node.js v18+ (or your runtime of choice)
- A Canvas API token ([how to generate one](https://community.canvaslms.com/t5/Student-Guide/How-do-I-manage-API-access-tokens-as-a-student/ta-p/273))
 
### Installation
 
```bash
git clone https://github.com/your-username/canvassync.git
cd canvassync
npm install
```
 
### Configuration
 
Create a `.env` file in the root directory:
 
```env
CANVAS_API_TOKEN=your_token_here
CANVAS_BASE_URL=https://your-institution.instructure.com
```
 
### Running the App
 
```bash
npm run dev
```
 
---
 
## Architecture
 
```
canvassync/
├── src/
│   ├── api/          # Canvas API client
│   ├── calendar/     # Calendar sync logic
│   ├── notifications/# Notification scheduler
│   └── ui/           # Frontend components
├── .env.example
└── README.md
```
 
---
 
## Contributing
 
Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.
 
1. Fork the repo
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a pull request
 
---
 
## License
 
[MIT](LICENSE)
 