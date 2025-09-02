# Linea  
A Reinvented Calendar Experience  

## Role  
Product Manager  
Developer  

## Portfolio Link  
[https://mantasviaz.framer.ai/projects/linea](https://mantasviaz.framer.ai/projects/linea)  

## Results  
- 93% faster event creation  
- Intuitive UX improving deadline visibility  

## Skills  
- User Interviews  
- Market Research  
- Iterative Design  
- UX/UI  

## Tools  
- Swift  
- LLM  
- OAuth  
- FastVLM  
- Spline  

---

## Problem  
Existing calendar and to-do apps made it difficult to **visually distinguish** which long-term deadlines were imminent, leading to **missed or rushed work**.

### Pain Points  
- **No sense of impending deadlines**: Standard calendar views (one-day due dates or extended blocks of time) don’t provide a visual “countdown” to deadlines, resulting in missed urgency cues and cluttered, unattractive displays when events are stretched across days.  
- **Lack of prioritization**: Users struggle to know what to work on at any given moment without a clear view of current workload.  
- **Time-consuming setup**: Adding assignments to calendars takes several minutes each, adding up to ~30 minutes weekly of manual input.  
- **Poor alignment with mental models**: People naturally think about time in terms of timelines or progressions, not just static boxes on specific days.  

---

## Research  

### Users  
After 10 user interviews, a few main personas emerged:  

**UNDERGRAD**  
- **Name**: Alex, 20  
- **Goals**: Balance multiple classes and projects, avoid last-minute cramming  
- **Frustrations**: Calendar clutter, forgetting intermediate milestones, no clear sense of progress  
- **Needs from Linea**: Quick setup, visual timeline of long assignments, proactive reminders  

**FREELANCER**  
- **Name**: Jordan, 32  
- **Goals**: Juggle multiple client projects, meet staged deliverables on time  
- **Frustrations**: Clients expect visibility; deadlines sneak up when only final due dates are logged  
- **Needs from Linea**: Clear Gantt-style tracking for multi-week deliverables, easy natural-language task input  

**GRAD RESEARCHER**  
- **Name**: Priya, 26  
- **Goals**: Manage overlapping research deadlines, teaching duties, and conferences  
- **Frustrations**: Large tasks span months, impossible to track progress in standard calendar tools  
- **Needs from Linea**: Granular breakdown of milestones, flexible rescheduling  

---

## Market  

Researching current tools showed key gaps for student, researcher, and freelancer workflows.  

| Competitor | Strengths | Limitations for Users |
|------------|-----------|------------------------|
| **ClickUp** | Free, integrations, flexible views | Cluttered interface; built for teams, not personal long-term projects |
| **TeamGantt** | Easy to use, mobile-friendly | Free plan limited; not tailored to multi-week personal workflows; meant for enterprise use |
| **Zoho Projects** | Affordable, Gantt + task dependencies | Enterprise-focused; lacks visual simplicity and quick import features |
| **Monday/Smartsheet/Wrike** | Powerful workflows, collaboration tools | Overkill for individuals; steep learning curve; not visually streamlined |
| **Tom’s Planner** | Simple, visual, personal Gantt | Manual setup; no NLP/image import; no app |

**Takeaways**:  
- **App-native tools** (ClickUp, Monday, TeamGantt) still skew enterprise/team, requiring lots of configuration, have cluttered interfaces creating high friction, and lack the quick upload feature from images or natural language.  
- **Web-only tools** (Tom’s Planner, GanttPRO) offer simplicity but lack the always-there, quick-entry nature of mobile apps.  

Linea will fill a unique niche: **a mobile-first, personal Gantt app built for individual workflows** (students, freelancers, researchers). It’s as quick to enter as Notes, but gives clarity and foresight like enterprise tools.  

### Market Sizing  
- **Addressable Market**: ~20 million undergrad students (US), plus grad students and freelancers globally. Many lack accessible tools tailored to visual, long-term planning.  
- **Competitive moat**: Those who used enterprise tools for planning often cited “too complex,” “cluttered,” or “not visual enough.” Linea’s simplicity and proactive approach can win favor.  

---

## Design  

### Lo-Fi  
The first prototypes were inspired by enterprise tools, with unlimited horizontal scrolling and tasks sorted by end date. I added a current-time line for orientation and a focus section to quickly highlight the most urgent milestones.  

Screens included:  
- Start/Login Screen  
- Home Screen  
- Adding Events  
- Event Detail View  

### Exploring Visual Approaches for Deadline Cues  
**How do I provide functionality without confusing the user?**  

- **Iteration 1**  
  - Hypothesis: Darker shades could signal urgency for user  
  - Feedback: Users felt overstimulated, struggled to parse meaning  
  - Decision: Rejected shading  

- **Iteration 2**  
  - Hypothesis: Opacity gradient could cue impending deadline  
  - Feedback: Users confused, hard to compare different color opacities  
  - Decision: Rejected due to confusion  

- **Iteration 3**  
  - Hypothesis: Adding text with due date could help with cues  
  - Feedback: Users found it indirect and not scannable  
  - Decision: Rejected as poor visual cue  

- **Iteration 4**  
  - Hypothesis: Simple pastel color reduce urgency but improve clarity  
  - Feedback: Users preferred the simplicity, even w/o cues  
  - Decision: Accepted as clearest  

**Takeaway**: *Clarity and calmness mattered more to users than added visual detail. I prioritized usability and focus, even at the cost of losing some functionality.*  

---

## Hi-Fi  
The final high-fidelity designs featured a clean UI, smooth animated start screen, and a color-coded home view. Event setup and editing were streamlined for speed and simplicity.  

Screens included:  
- Start/Login Screen  
- Home Screen  
- Adding Events  
- Event Detail View  

---

## Implementation  

### Cloud vs. On-Device Models  
While choosing different models for the natural language and image input features, I faced the decision of whether to run them in the **cloud** or **on-device**.  

**Option 1: Cloud Models** (ex. GPT-4o, Claude, Gemini, LLaMa)  
- **Pros**: Higher accuracy, faster iteration, scalable with user base  
- **Cons**: Slower than on-device, per-call costs, privacy concerns  

**Option 2: On-Device Models** (ex. Apple’s FastVLM, LLaMa 3 small variant, TinyBERT)  
- **Pros**: Works offline, lower latency, no per-call cost, stronger privacy  
- **Cons**: Limited by device compute, large app size, overheating, privacy risks still present  

**Comparison**:  

| Criteria | OpenAI’s GPT-4o | Apple’s FastVLM | Takeaway |
|----------|-----------------|-----------------|----------|
| Accuracy | ~95% correct + greater semantic understanding | ~50% correct, less predictable | Cloud more reliable for MVP |
| Latency | ~1 min upload + response | 30s avg, inconsistent | Cloud more consistent, on-device faster at times |
| Cost | $0.02 per request | Free | On-device more scalable long-term |
| App Size | No change | +5GB increase, overheating/crashing | Cloud lighter, better device performance |

**Conclusion**: On-device models proved to be **less reliable**. For Linea’s MVP, I chose **cloud models** because accuracy and flexibility were most critical to validating the value proposition.  

---

## Scoping of Features  

After generating a list of feature ideas, I evaluated each across **user pain addressed**, **development effort required**, **level of differentiation**, and **criticality to the product’s core value**.  

| Feature | User Pain | Dev Effort | Differentiation | Criticality |
|---------|-----------|------------|-----------------|-------------|
| Gantt Timeline Builder | High | Medium | Low | Must-Have |
| Natural Language Event Creation | High | Low | High | Should-Have |
| Import from Image (VLM) | High | Medium | High | Should-Have |
| Today’s Focus Section | High | Medium | Medium | Should-Have |
| Calendar Sync | Medium | Medium | Low | Should-Have |
| Collaboration / Shared Timelines | Medium/Low | High | Medium | Nice-to-Have |
| Export to PDF / Shareable Views | Low | Low | Low | Could-Have |

From this evaluation, I defined the **must-have** and **should-have** features as the scope for the initial MVP, while the remaining features were **deferred to the future roadmap**.  

---

## Results  

### Challenges  
One challenge I faced was the **uncertainty of estimating development effort**, especially for a core feature like the timeline builder. I underestimated the time it would take to refine, debug unexpected rendering issues, and fine-tune interactions.  

**What I learned**: I now build in **buffer space** when scoping critical features to account for both complexity and debugging cycles.  

### Metrics  
Although I wasn’t able to publish on the App Store, I distributed local builds to test users and observed the following impacts:  

- **93% faster event creation** (for 30 events: 30 min manually vs. 2 min upload)  
- **User-reported increase in time management and deadline discipline**  

### Future Metrics to Track  
- **Activation rate** (% of users who create a timeline in their first session)  
- **Retention (D7, D30)** (how many users return after one week or one month)  
- **On-time completion rate** (% of milestones finished by their deadlines)  
- **Feature usage mix** (relative use of manual entry, natural language input, and image imports)  
