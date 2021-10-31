using ProofOfConcept
using Documenter

DocMeta.setdocmeta!(ProofOfConcept, :DocTestSetup, :(using ProofOfConcept); recursive=true)

makedocs(;
    modules=[ProofOfConcept],
    authors="Albert Oliver <albert.oliver@ulpgc.es> and contributors",
    repo="https://github.com/albert-oliver/ProofOfConcept.jl/blob/{commit}{path}#{line}",
    sitename="ProofOfConcept.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
