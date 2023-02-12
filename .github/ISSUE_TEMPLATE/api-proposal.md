---
name: API Proposal
about: Template for API change proposals.
title: 'proposal: '
labels: 'proposal: proposed'
assignees: ''

---

# Summary

Summary of what you want this API to achieve.

# Contributors

- Your Name, [@yourgithub](https://github.com/)

# Status

- [ ] Proposed
- [ ] Discussed with the community
- [ ] Approved
- [ ] Implemented

# Design Decisions

<!-- THIS SECTION IS OPTIONAL -->

An explanation of any notable design decisions you made (i.e. why you designed the API the way you did).

# Proposed API

Here you make some blocks of code, this is the heart and soul of the proposal.

```lua
---Represents a grenade.
local Grenade = {}

---What does it do?!?
Grenade.red_button = function(self)
end

---Detonates the grenade.
---
---@protected
Grenade.kaboom = function(self)
end

---Gets or sets whether this grenade is disarmed or not.
Grenade.disarmed = false
```
