module ProofOfConcept

using LinearAlgebra

import Base: *, ==

export Triangle
export Point
export get_barycentric_coordinates
export *
export ==
export is_inside
export refinement_criteria
export TerrainMap
export look_for_points_inside_triangle
export distribute_and_mark_for_refinement

# Write your package code here.
struct Point
    coords::Vector{Real}
    height::Real
end

function Point(coords)
    return Point(coords, NaN)
end

function get_coords(p::Point)
    return p.coords
end

function ==(p::Point, v)
return all(p.coords ≈ v)
end

struct Triangle
    coords::Matrix{Real}
    height::Vector{Real}
end

function Triangle(m)
    t = Triangle(m, similar(m, length(m)))
end

function Triangle(p1, p2, p3)
    return Triangle([p1 p2 p3])
end

function Triangle(p1::Point, p2, p3)
    return Triangle([get_coords(p1) p2 p3])
end

function get_v1(t)
    return t.coords[:,1]
end

function get_v2(t)
    return t.coords[:,2]
end

function get_v3(t)
    return t.coords[:,3]
end

function get_area(t)
    t_v1 = get_v2(t) - get_v1(t)
    t_v2 = get_v3(t) - get_v1(t)

    return det([t_v1 t_v2])/2
end


function get_barycentric_coordinates(p, t)
    t_area = get_area(t)
    t1 = Triangle(p, get_v2(t), get_v3(t))
    t1_area = get_area(t1)
    t2 = Triangle(p, get_v3(t), get_v1(t))
    t2_area = get_area(t2)
    t3 = Triangle(p, get_v1(t), get_v2(t))
    t3_area = get_area(t3)

    return [t1_area/t_area, t2_area/t_area, t3_area/t_area]
end

function ⪅(a, b)
return (a < b) || (a ≈ b)
end

function is_inside(bc)
    return all(0 .⪅ bc .⪅ 1)
end


function is_inside(p::Point, t::Triangle)
    bc = get_barycentric_coordinates(p, t)
    return is_inside(bc)
end

function *(bc, t::Triangle)
return t.coords * bc 
end

function refinement_criteria(bc, p::Point, t::Triangle, tol::Real)
    t_height = dot(bc, t.height)
    return abs(p.height - t_height) > tol
end

function refinement_criteria(p::Point, t::Triangle, tol::Real)
    bc = get_barycentric_coordinates(p, t)
    return refinement_criteria(bc, p, t, tol)
end

# The map starts at the point (lon_min, lat_min)
# and moves first on longitude and then on latitude
struct TerrainMap
    lat_min::Real
    lon_min::Real
    Δ_lat::Real
    Δ_lon::Real
    height::Matrix{Real}
end

function get_point(m::TerrainMap, idx::CartesianIndex)
    lon = m.lon_min + (idx[1] - 1) * m.Δ_lon
    lat = m.lat_min + (idx[2] - 1) * m.Δ_lat
    height = m.height[idx]
    return Point([lon, lat], height)
end

function get_point(idx::CartesianIndex, m::TerrainMap)
    return get_point(m, idx)
end

function is_inside(m::TerrainMap, idx::CartesianIndex, t::Triangle)
    return is_inside(get_point(m, idx), t)
end

function refinement_criteria(m::TerrainMap, idx::CartesianIndex, t::Triangle, tol::Real)
    return refinement_criteria(get_point(m, idx), t, tol)
end

function look_for_points_inside_triangle(m::TerrainMap, t::Triangle)
    return idx -> is_inside(m, idx, t)
end

function get_barycentric_coordinates(m::TerrainMap, idx::CartesianIndex, t::Triangle)
    return get_barycentric_coordinates(get_point(m, idx), t)
end

function distribute_and_mark_for_refinement(m::TerrainMap, parent_indices, son_t::Triangle, tol::Real)
    pts = map(x -> get_point(m, x), parent_indices)
    bc = map(x -> get_barycentric_coordinates(x, son_t), pts)
    local_indices = findall(is_inside, bc)
    son_indices = view(parent_indices, local_indices)
    refine = any(i -> refinement_criteria(bc[i], pts[i], son_t, tol), local_indices)
    return (refine, son_indices)
end

end
