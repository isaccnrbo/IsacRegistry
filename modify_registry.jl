#!/usr/bin/env -S julia --color=yes --startup-file=no
using Pkg
try
    using LocalRegistry
    using ArgParse
catch e
   Pkg.add(["LocalRegistry","ArgParse"])
   using LocalRegistry
   using ArgParse
end

const giturlregex = r"^[a-zA-Z][a-zA-Z\d+\-.]*//:.+/,+/.+(.git)?$"
isurl(str::String)= occursin(giturlregex,str)
isurl(x::Dict)= isurl(x["url"])
isrm(cmd::String)= cmd=="remove";
isrm(x::Dict)=isrm(x["%COMMAND%"]);
iscreate(cmd::String)= cmd=="create";
iscreate(x::Dict)=iscreate(x["%COMMAND%"]);
isadd(cmd::String)= cmd=="add";
isadd(x::Dict)=isadd(x["%COMMAND%"]);
islistreg(cmd::String)= cmd=="list";
islistreg(x::Dict)=islistreg(x["%COMMAND%"]);

function main(args)
    settings = ArgParseSettings("Script to add and remove a local registry to the Julia environment");

    @add_arg_table! settings begin
        "remove"
            action = :command
            help = "Remove existing registry"
        "add"
            action = :command
            help = "Equivalent to $PROGRAM_FILE NAME"

        "create"
            action = :command
            help = "Equivalent to $PROGRAM_FILE NAME"
        "list"
            action = :command
            help = "List all all registries currently in use"
    end

    @add_arg_table! settings begin
        "--name"
            help = "Set the name of the repository  [required for remove]"
            arg_type = String
        "--url"
            help = "Set the url of the repository [required for add/create] "
            arg_type = String
        "--path"
            help = "Set the path of the repository [required for create]"
            arg_type = String
        "--description","-d"
            help = "Set the description of the repository [optional for create]"
            arg_type = String
            default = "Private Julia Registry"
    end


    settings.epilog= """
            To add a repository:\n
            \n
            \ua0\ua0$(basename(Base.source_path()))  --url URL add\n
            \n
            To remove a repository:\n
            \n
            \ua0\ua0$(basename(Base.source_path())) --name NAME remove\n
            \n
            \n
            To create a repository:\n
            \n
            \ua0\ua0$(basename(Base.source_path())) --path PATH --url URL [-d DESCRIPTION] create\n
            \n
            To list all repositories currently available:\n
            \n
            \ua0\ua0$(basename(Base.source_path())) list\n
            \n

            Notes: \n
            \ua0\ua0 1. NAME and URL are not allowed to have spaces\n
            \n
            \ua0\ua0 2. string of text for description needs to be between \"\"
            if longer than one word.\n
            \n
            \ua0\ua0 3. the URL of the repository is given in the format:\n
            \ua0\ua0\ua0\ua0\ua0\ua0\ua0\ua0 https://git.isac.cnr.it/USER/REGISTRY\n
            """


    parsed_args = parse_args(args, settings)

    if iscreate(parsed_args)
        println("Creating registry")
        @show parsed_args
        (isnothing(parsed_args["path"]) || isnothing(parsed_args["url"])) ? throw(ArgumentError("--name and --url are not defined for create")) : nothing
        !isnothing(parsed_args["name"]) ? throw(ArgumentError("--name is not allowed for create")) : nothing

        println("Path: ",parsed_args["path"]); path=abspath(parsed_args["path"])
        println("URL: ",parsed_args["url"]); url=parsed_args["url"]
        println("Description: ",parsed_args["description"]); description=parsed_args["description"]
        try
            create_registry(path,url; description=description,push = true)
        catch e
            @show e
            warning("Registry already exists")
        end
            reg=RegistrySpec(url=parsed_args["url"])
        Pkg.Registry.add(reg)
        exit(0)

    end
    if isrm(parsed_args)
        !isnothing(parsed_args["path"]) ? throw(ArgumentError("--path is not allowed for remove")) : nothing
        !isnothing(parsed_args["url"]) ? throw(ArgumentError("--url is not allowed for remove")) : nothing
        isnothing(parsed_args["name"]) ? throw(ArgumentError("--name is required for remove")) : nothing

        println("Removing registry")
        if !isnothing(parsed_args["name"])
            reg=RegistrySpec(parsed_args["name"])
        else
            reg=RegistrySpec(url=parsed_args["url"])
        end
        Pkg.Registry.rm(reg)

        exit(0)
    end

    if isadd(parsed_args)
        !isnothing(parsed_args["path"]) ? throw(ArgumentError("--path is not allowed for add")) : nothing
        !isnothing(parsed_args["name"]) ? throw(ArgumentError("--name is not allowed for add")) : nothing
        isnothing(parsed_args["url"]) ? throw(ArgumentError("--url is needed for add")) : nothing
        println("Adding registry")
        println("URL: ",parsed_args["url"])
        reg=RegistrySpec(url=parsed_args["url"])
        Pkg.Registry.add(reg)
        exit(0)
    end

    if islistreg(parsed_args)
        println("Listing registries")
        Pkg.Registry.status()
        exit(0)
    end
    exit(1)

end

main(ARGS)
