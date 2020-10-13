---
title: "3 Ways to Simplify Your ASP.NET Authorization Code"
date: 2020-10-08T11:39:03-07:00
draft: true
---

1) Reduce the Scope to "3 Ways to Simplify Your Authorizations in ASP.NET" (?)
2) Way the first - Layer Your Policies
    - People assume they have to confirm all assertions in one policy
    - People assume they can write one handler to deal with a whole policy
    - People assume that everything has to happen before it hits the controller method
    - Advantage is that this short-circuits quickly and in a tiered approach. Least amount of work is done for the most obvious situations.
3) Leverage Your existing Domain model -- This means use strongly-typed handlers
4) You are allowed to put checks on your requirements.


## Intro - Bloated Authorization Handlers

### Too Much Handler Logic


### Reading from HttpContext


### The Important of Testability
* We want to have Authorization Handlers that are easily testable. This means the least amount of assumptions possible. 
* HttpContext is a giant bag of challenges to mock

## 1) Tier Your Policies

### Tier 1 - Have a base set of policies that focus on Role, Claims, and simple Assertions

* This is where we get the easy stuff out of the way
* Are you authenticated?
* Is this a tightly focused microservice? You might want to verify a specific scope or set of claims.
* Get as much done in this layer as you can

### Tier 2 - Use Targeted Handlers in your Controller methods

* Load the resource you're authorizing, you're probably going to do it anyway.
* Use *very* targeted handlers that handle the specific resource or issue
* This allows you to be deliberate about your status code. Sometimes you might want to hide authorization issues behind a 404.
* This allows you to handle complex scenarios
* You can identify patterns in handlers which will inform your work for the next tip.

## 2) Enrich your User/ClaimsPrincipal with additional claims

* The point of doing this is to manage your 
* Ideally this should be cached
* Drawback is you have to manage cache invalidation

### Model Your Access Map

* Image: "Project -> User -> Manager"

### 

## Structure your resource access to not require authorization

Often we think of complex authorization schemes to control access to resources, but the need for this architecture is often eschewed by the application requirements in the first place. Consider an API controller like this:

```csharp
[Route("api/projects/")]
[ApiController]
public class ProjectsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public ProjectsController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [Authorize]
    public async Task<ActionResult<IEnumerable<Project>>> GetUserProjects()
    {
        var user = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        // Query is constrained to the authenticated user.
        var projects = await _db.Projects
            .Where(p => p.UserId == user)
            .ToListAsync();

        return projects;
    }
}
```

The business requirement for a controller like this is common and deceptively simple:
1) A User should be able to query for a list of projects.
2) A User should only be able to see projects which belong to them.

The only code we have that points toward authorization is a single `[Authorize]` attribute on the controller. Assuming we use the ASP.NET Core defaults, this already ensures that the user has been authenticated. From here we accomplish both requirements by just constraining the query. 

### Advantages
* Does not require complex authorization code
* Not vulnerable to an authorization bypass. 
* The client and server do not need to handle a 'forbidden' case. The only result is an empty collection.

### Disadvantages
* Extending the functionality of the endpoint without careful consideration could lead to [insecure direct object references](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html).

### When to Use
* When specific resources are owned by the user or by an entity that relates to the user (e.g. a 'Company' or 'Organization').

### When to Avoid
* When the parameters are not guaranteed to be safe. If `user` were pulled up into a parameter on the method, if would no longer be available to use without direct validation.

## Stick to Simple Primitives as much a possible
* Claims
* Assertions
* Roles (if using)

## Employ a Tiered Approach to saying "No"

## Leverage Your Existing Permissions Model
* Don't shoehorn a robust model you already have into a pipeline where it doesn't fit.
* If your permissions API fits just fine into an AuthorizationHandler, great! Otherwise you can just run your existing checks and return Unauthorized(); 

## When You Write a Custom AuthorizationHandler

### AuthorizationHandlers can deal with more complex access control requirements

### You're doing too much. Assert as little as possible for a requirement

### Short-Circuit Quickly if Your Check Won't Change the Outcome

### Invoking Custom Handlers is Probably Best Done Imperatively

### Caching Results of Custom Handlers



