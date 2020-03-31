---
layout: article
title: "Hacking the Pleroma: Elixir, Phoenix and a bit of ActivityPub"
date: 2018-04-19
modified: 2018-04-19
tags: [ coding, hacking, programming, elixir, pleroma ]
excerpt: "A brief guide into hacking Pleroma, a federated microblogging server software."
current: "Hacking the Pleroma: Elixir, Phoenix and a bit of ActivityPub"
current_image: hacking-pleroma_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: hacking-pleroma_1600x600.jpg
  teaser: hacking-pleroma_400x150.jpg
  thumb: hacking-pleroma_400x150.jpg
---

[Pleroma](https://pleroma.social/) "is a microblogging server software that can federate (= exchange messages with) other servers that support the same federation standards (OStatus and ActivityPub). What that means is that you can host a server for yourself or your friends and stay in control of your online identity, but still exchange messages with people on larger servers. Pleroma will federate with all servers that implement either OStatus or ActivityPub, like GNU Social, Friendica, Hubzilla and Mastodon." [(stolen from Lain's blog post)](https://blog.soykaf.com/post/what-is-pleroma/).

Recently I modified my Pleroma instance to support bot services: parse a posted message, take an action, post the result. To get there I had to learn [Elixir](https://elixir-lang.org/), the language in which Pleroma is written, as well as [Phoenix](https://hexdocs.pm/phoenix/overview.html), the web framework Elixir uses, and a little bit about ActivityPub, the protocol for exchanging messages. What I want to explain here in particular is the architecture of Pleroma, so that you can hack it more easily, for fun or if you want to participate in the development.

## Elixir

As Pleroma is written in [Elixir](https://elixir-lang.org/) you'll need to learn that language to some extent. If you are familiar with Ruby (or Perl, for that matter) and with the idea of functional programming (everything is a function), then it is quite easy to learn and understand. The [documentation](https://hexdocs.pm/elixir/) and [guides](https://elixir-lang.org/getting-started/introduction.html) are very good. 

If you've never hear of functional programming, the main difference with e.g. Ruby or Java is that Elixir does not use an object-oriented programming model. Instead, there are functions that manipulate data structures and other functions. A particular consequence of the functional model is that there are no for- or while-loops. Instead, there are what is called higher-order functions which e.g. apply another function to a list. Elixir programs also make a lot more use of recursion. 

Another point about Elixir as a web programming language is that it is built on a system where processes communicate by passing messages to one another, and it is  built in such a way that if a process dies it will normally be restarted automatically. This approach makes it very easy to offload work to separate worker processes etc. 

All this comes courtesy of [Erlang](https://www.erlang.org/), the language on which Elixir is built, with its powerfull OTP framework for building applications and its BEAM virtual machine, which manages the processes. 

## Phoenix

A lot of the groundwork of Pleroma is done by [Phoenix](https://hexdocs.pm/phoenix/overview.html), a very easy-to-use web server framework. Essentially, what happens is that the end user accesses the application using a specific url, typically via a web browser, and based on this url the application performs a number of actions, which in the end result in a change in the state of the application and usually in what is shown in the browser window.

In Phoenix, there are five stages or components  between the connection and the resulting action by the application:

### Endpoint

The [endpoint](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html) is the boundary where all requests to your web application start. It is also the interface your application provides to the underlying web servers.

Pleroma's endpoint is [`web/endpoint.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/endpoint.ex). If you look at the source you see several occurrences of `plug(Plug...)`. [Plug](https://hexdocs.pm/phoenix/plug.html) is a specification for composable modules in between web applications, and it is very heavily used in Pleroma.  For example, to serve only specific static files/folders from `priv/static`:

```elixir
plug(
  Plug.Static,
  at: "/",
  from: :pleroma,
  only: ~w(index.html static finmoji emoji packs sounds images instance sw.js)
)
```

Another very nice feature of Phoenis is that you can edit your code while your server is running. It gets automatically recompiled and the affected processes are automatically restarted, courtesy of the [Phoenix.CodeReloader](https://hexdocs.pm/phoenix/Phoenix.CodeReloader.html):

```elixir
  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end
```


### Router

[Routers](https://hexdocs.pm/phoenix/Phoenix.Router.html) are the main hubs of Phoenix applications. They match HTTP requests to controller actions, wire up real-time channel handlers, and define a series of pipeline transformations for scoping middleware to sets of routes.

Pleroma's router is [`web/router.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/router.ex). The key function in the router is the `pipeline` which lets you create pipelines of plugs. Other functions are `scope`, `get`, `post`, `pipe_through`, all of these let you match on the url and whether you are dealing with a get or post request, and define appropriate pipelines of actions. For example, federated ActivityPub requests handled as follows:

```elixir
scope "/", Pleroma.Web.ActivityPub do
  pipe_through(:activitypub)
  post("/users/:nickname/inbox", ActivityPubController, :inbox)
  post("/inbox", ActivityPubController, :inbox)
end
```
where the `pipe_through(:activitypub)` call is used to insert a custom pipeline:

```elixir
pipeline :activitypub do
  plug(:accepts, ["activity+json"])
  plug(Pleroma.Web.Plugs.HTTPSignaturePlug)
end
```  

### Controllers

[Controllers](https://hexdocs.pm/phoenix/Phoenix.Controller.htm) are used to group common functionality in the same (pluggable) module.  

Pleroma makes heavy use of controllers: almost every request is handled by a specific controller for any given protocol, e.g. `MastodonAPIController` or `ActivityPubController`. This makes it easy to identify the files to work on if you need to make a change to the code for a given protocol. For example, the ActivityPub post requests in the Router are handled by `inbox` function in the [ActivityPubController](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/activity_pub/activity_pub_controller.ex):

```elixir
def inbox(%{assigns: %{valid_signature: true}} = conn, params) do
  Federator.enqueue(:incoming_ap_doc, params)
  json(conn, "ok")
end
```

### Views

[Views](https://hexdocs.pm/phoenix/Phoenix.View.html) are used to control the rendering of templates. You create a view module, a template and a set of assigns, which are basically key-value pairs.

Pleroma uses views for "rendering" JSON objects. For example in [`web/activity_pub/activity_pub_controller.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/activity_pub/activity_pub_controller.ex) there are lines like

```elixir
json(UserView.render("user.json", %{user: user}))
```
Here, `UserView.render` is defined in [`web/activity_pub/views/user_view.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/activity_pub/views/user_view.ex) for a number of different "*.json" strings. These are not really templates, they are simply used to pattern match on the function definitions.

The more conventional usage to create HTML is also used, e.g. the template [`web/templates/mastodon_api/mastodon/index.html.eex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/templates/mastodon_api/mastodon/index.html.eex)
is used in [`web/mastodon_api/mastodon_api_controller.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/mastodon_api/mastodon_api_controller.ex) via the view
[`web/mastodon_api/views/mastodon_view.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/mastodon_api/views/mastodon_view.ex):

```elixir
render(MastodonView, "index.html", %{initial_state: initial_state})
```
### Templates

[Templates](https://hexdocs.pm/phoenix/Phoenix.Template.html) are text files (typically html pages) with Elixir code to generate the specific values based on the assigns, included in `<%= ... %>`.

For example, in Pleroma, the Mastodon front-end uses a template for the `index.html` file which has the code

```elixir
<%= Application.get_env(:pleroma, :instance)[:name] %>
```
to show the name of the instance.

## Ecto

[Ecto](https://hexdocs.pm/ecto/Ecto.html) is not a part of Phoenix, but it is an integral part of most web applications: Ecto is Elixir's main library for working with databases. It provides the tools to interact with databases under a common API.

Ecto is split into 4 main components:

Ecto.Repo - repositories are wrappers around the data store. Via the repository, we can create, update, destroy and query existing entries. A repository needs an adapter and credentials to communicate to the database

Pleroma uses the PostgresQL database.

Ecto.Schema - schemas are used mainly to map tables into Elixir data (there are other use cases too).

Ecto.Changeset - changesets provide a way for developers to filter and cast external parameters, as well as a mechanism to track and validate changes before they are applied to your data

Ecto.Query - written in Elixir syntax, queries are used to retrieve information from the database.

## GenServer

Because Elixir, like Erlang, uses a processes-with-message-passing paradigm, client-server relationships are so common that they have been abstracted as a _behaviour_, which in Elixir is a specification for composable modules which have to implement specified public functions (a bit like an interface in Java or typeclass in Haskell).

If we look at the `Federator.enqueue` function, its implementation actually reduces to a single line:

```elixir
GenServer.cast(__MODULE__, {:enqueue, type, payload, priority})
```
[GenServer](https://hexdocs.pm/elixir/GenServer.html) is an Elixir behaviour module for implementing the server of a client-server relation. The `cast` call sends an asynchronous request to the server (synchronous requests use `call`). The server behaviour is implemented using the `handle_cast` callback, which handles `cast` calls. 

In [`Pleroma.Federator`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/federator/federator.ex), these are implemented in the same module as the `enqueue` function, hence the use of `__MODULE__` rather than the hardcoded module name.

## Applications, Workers and Supervisors

Elixir borrows the concept of a "supervision tree" from Erlang/OTP. AN application consists of a tree of processes than can either be _supervisors_ or _workers_. The task of a supervisors is to ensure that the worker processes do their work, including distributing the work and restarting the worker processes when they die. Supervisors can supervise either worker or other supervisors, so you can build a _supervision tree_.

Elixir provides an [Application](http://elixir-lang.org/docs/stable/elixir/Application.html) behaviour module and a [Supervisor](https://hexdocs.pm/elixir/Supervisor.html) module to make this easy. The Application module requires a `start()` function as entry point. Typical code to create a supervision tree is

```elixir
Supervisor.start_link(children, opts)
```

where `start_link()` spawns the top process of the tree, and it spawns all the child processes in the list `children`. 

Pleroma uses a convenient but deprecated module called [Supervisor.Spec](https://hexdocs.pm/elixir/Supervisor.Spec.html) which provides `worker()` and `supervisor()` functions, for example:

```elixir
children = [
  supervisor(Pleroma.Repo, []),
  supervisor(Pleroma.Web.Endpoint, []),
  # ...
  worker(Pleroma.Web.Federator, []),
  # ...
]  
```

Every worker has this own `start_link` function,  e.g.  in [`web/federator/federator.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/federator/federator.ex) we find: 

```elixir
def start_link do
  # ...
  GenServer.start_link(__MODULE__, ...)
end
```

This means that the Federator module borrows the `start_link` from the GenServer module. This is a very common way to create a worker.

## Mix

[Mix](https://hexdocs.pm/mix/Mix.html) is the build tool for Elixir, and its main advantage is that the build scripts are also written in Elixir. Some key `mix` actions are provided by Phoenix, for example to build and run the final Pleroma application the action is `mix phx.server`.

## Hacking Pleroma

After this brief tour of Elixir and Phoenix I want to give an example of adding simple bot functionality to Pleroma. See [my fork of Pleroma](https://git.pleroma.social/andarna/pleroma) for the code.

My bot parses incoming messages for `@pixelbot`, extracts a list of pixel from the message, modifies a canvas with the new pixels and creates a PNG image of the result. It then posts a link to the PNG image. 

### Adding a worker

Because updating the canvas and creating the PNG image could be time-consuming, especially if the canvas were large, I put this functionality in a separate server module, and added this to the list of workers for the [main Pleroma application](https://git.pleroma.social/andarna/pleroma/tree/develop/lib/pleroma/application.ex):

```elixir
    children = [
      ...
    ] ++ if !bot_enabled(), do: [], else: [
      worker(Pleroma.Bots.PixelBot, [ get_canvas_size()  ],id: PixelBot),
    ]
```

The bot takes the size of the canvas from my [`config.exs`](https://git.pleroma.social/andarna/pleroma/blob/develop/config/config.exs) using the helper function `get_canvas_size()`. The `id: PixelBot` allows to access the worker by name.

When the application starts, it launches the PixelBot worker ([`bots/pixelbot.ex`](https://git.pleroma.social/andarna/pleroma/tree/develop/lib/pleroma/bots/pixelbot.ex)). The worker calls its `init()` function (part of the GenServer behaviour) which loads the last canvas from a file.

### A bit of ActivityPub

One of the protocols used for federation is [ActivityPub](https://www.w3.org/TR/activitypub/). The specification is long and not so easy to read. However, for the purpose of hacking Pleroma it mainly
helps to understand the structure of an ActivityPub _action_ (in this case a post):

```elixir
activity = %{
 actor: user_url<>,
 data: %{"actor" => user_url,
   "cc" => [user_url<>"/followers"],
   "context" => instance_url<>"/contexts/" <> context_id,
   "id" => instance_url<>"/activities/" <> activity_id,
   "object" => %{"actor" => user_url<>,
     "attachment" => [%{"name" => image_file_name, "type" => "Image",
       "url" => [
           "href" => instance_url<>"/media/"<>uuid<>"/"<>image_file_name,
           "mediaType" => "image/png", "type" => "Link"
         }
       ],
       "uuid" => uuid}
     ],
     "cc" => [user_url<>"/followers"],
     "content" => content_str,
     "context" => instance_url<>"/contexts/"<>context_id,
     "emoji" => %{},
     "id" => instance_url<>"/objects/"<>object_id, 
     "published" => now, "summary" => "", "tag" => [],
     "to" => ["https://www.w3.org/ns/activitystreams#Public"],
     "type" => "Note"
   }, "published" => now,
   "to" => ["https://www.w3.org/ns/activitystreams#Public"],
   "type" => "Create"
 }, id: id, inserted_at: ndt,
 local: true,
 recipients: ["https://www.w3.org/ns/activitystreams#Public", user_url<>"/followers"],
 updated_at: ndt
}
```

In my case, 

```elixir
instance_url="https://pynq.limited.systems"
user_url = user_url<>"/users/pixelbot"`
image_file_name = "canvas.png"
content_str = "Canvas:<br><a href=\""
  <>instance_url
  <>"/media/"<>uuid<>"/"<>image_file_name
  <>"\" class='attachment'>"
  <>image_file_name
  <>"</a>"
```

In Pleroma this activity is linked to the Ecto repository Pleroma.Repo ([`repo.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/repo.ex)) in the module Pleroma.Activity ([`activity.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/activity.ex)), which defines a schema.


### Getting the messages

The bot only supports ActivityPub. As we have seen above, in Pleroma incoming messages are handled by `inbox` function in the ActivityPubController (in [`web/activity_pub/activity_pub_controller.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/activity_pub/activity_pub_controller.ex)), so I put in a little hook there to detect if a message is for `@pixelbot` and has an actual message body (`content`):

```elixir
def inbox(%{assigns: %{valid_signature: true}} = conn, params) do
  headers = Enum.into(conn.req_headers, %{})
  if is_map(params) and Map.has_key?(params,"nickname") and Map.has_key?(params,"object") do
    if params["nickname"] == "pixelbot" and is_map(params["object"]) and Map.has_key?(params["object"],"content") do
        content =  params["object"]["content"]
        GenServer.cast(Pleroma.Bots.PixelBot,content)
        :ok
    else
      :nok
    end
  else
    :nok
  end
```

As you can see, the content of a message for `@pixelbot` is passed on to the PixelBot worker for processing using the `GenServer.cast(Pleroma.Bots.PixelBot,content)` call.

### Processing the messages

The PixelBot worker parses the message to extract any pixels from it ([`bots/pixelbot/parse_messages.ex`](https://git.pleroma.social/andarna/pleroma/tree/develop/lib/pleroma/bots/pixelbot/parse_messages.ex)). If there are any, it updates the canvas (which is just a list of lists). It and writes the content to a file, and calls an external program to create the final image. 

### Posting a reply

Finally, the bot posts a status to the public timeline ([`bots/pixelbot/pixelbot_post_status.ex`](https://git.pleroma.social/andarna/pleroma/tree/develop/lib/pleroma/bots/pixelbot/pixelbot_post_status.ex)). The status contains the current time and a link to the latest canvas.  The function `pixelbot_post_status()` creates the status and wraps it in the correct structure required by ActivityPub. 

It also gets the user object based on the nickname via [`Pleroma.User.get_cached_by_nickname(nickname)`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/user.ex). Like the activity, this user object is defined via a schema and linked to the Ecto repository (in [`user.ex`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/user.ex)). So `user` in the code below is a complicated object, not a url or nickname.

Finally, the function calls [`ActivityPub.create()`](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/web/activity_pub/activity_pub.ex) which creates the activity, and in this case that means it posts a status.

```elixir
  def pixelbot_post_status() do
    now = DateTime.to_string(DateTime.utc_now())
    nickname="pixelbot"
    user = Pleroma.User.get_cached_by_nickname(nickname)
    visibility = "public" #get_visibility(data)

    instance_url="https://pynq.limited.systems"
    user_url = user_url<>"/users/pixelbot"`
    image_file_name = "canvas_512x512.png"


    to =  ["https://www.w3.org/ns/activitystreams#Public"]
    cc =  [user_url <> "/followers"]

    context = instance_url <>"/contexts/pixelbot-dummy-context"
    object = %{"actor" => user_url,
            "attachment" => [%{"name" => image_file_name, "type" => "Image",
              "url" => [%{"href" => instance_url<> "/pixelbot/"<>image_file_name,
                "mediaType" => "image/png", "type" => "Link"}],
              "uuid" => "pixelbot-dummy-uuid"
            }],
            "cc" => [user_url<>"/followers"],
            "content" => "Canvas at "<>now<>"<br><a href=\""<>instance_url<>"/pixelbot/"<>image_file_name<>"\" class='attachment'>"<>image_file_name<>"</a>",
            "context" => context,
            "emoji" => %{}, "summary" => nil, "tag" => [],
            "to" => ["https://www.w3.org/ns/activitystreams#Public"], "type" => "Note"
          }

    res =
            Pleroma.Web.ActivityPub.ActivityPub.create(%{
              to: to,
              actor: user,
              context: context,
              object: object,
              additional: %{"cc" => cc}
            })
    Pleroma.User.increase_note_count(user)
    res
  end

```

## Pleroma source tree 

This is only a part of the [Pleroma source tree](https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/pleroma/), it shows on the files mentioned above.

    /lib/pleroma/
    ├── activity.ex
    ├── application.ex
    ├── notification.ex
    ├── object.ex
    ├── plugs
    │   ├── authentication_plug.ex
    │   ├── http_signature.ex
    │   └── oauth_plug.ex
    ├── repo.ex
    ├── user.ex
    └── web
        ├── activity_pub
        │   ├── activity_pub.ex
        │   ├── activity_pub_controller.ex
        │   ├── transmogrifier.ex
        │   ├── utils.ex
        │   └── views
        │       ├── object_view.ex
        │       └── user_view.ex
        ├── common_api
        │   ├── common_api.ex
        │   └── utils.ex
        ├── endpoint.ex
        ├── federator
        │   └── federator.ex
        ├── mastodon_api
        │   ├── mastodon_api.ex
        │   ├── mastodon_api_controller.ex
        │   ├── mastodon_socket.ex
        │   └── views
        │       ├── mastodon_view.ex
        ├── router.ex
        ├── templates
        │   ├── mastodon_api
        │   │   └── mastodon
        │   │       ├── index.html.eex
        ├── web.ex
        ├── web_finger
        │   ├── web_finger.ex
        │   └── web_finger_controller.ex


