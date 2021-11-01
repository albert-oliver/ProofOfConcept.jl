using ProofOfConcept
using Test

@testset "Barycentric coordinates" begin
    t = Triangle([0, 0], [1, 0], [0, 1])
    p1 = Point([0.1, 0.1])
    bc = get_barycentric_coordinates(p1, t)
    @test p1 == bc * t

    p2 = Point([0.2, 0.1])
    bc = get_barycentric_coordinates(p2, t)
    @test p2 == bc * t

    p3 = Point([0.8, 0.1])
    bc = get_barycentric_coordinates(p3, t)
    @test p3 == bc * t

    p4 = Point([1.8, -2.1])
    bc = get_barycentric_coordinates(p4, t)
    @test p4 == bc * t
end

@testset "is_inside" begin
    t = Triangle([0, 0], [1, 0], [0, 1])


    p1 = Point([0.1, 0.1])
    @test is_inside(p1, t)
    bc = get_barycentric_coordinates(p1, t)
    @test is_inside(bc)

    p2 = Point([0.2, 0.1])
    @test is_inside(p2, t)
    bc = get_barycentric_coordinates(p2, t)
    @test is_inside(bc)

    p3 = Point([0.8, 0.1])
    @test is_inside(p3, t)
    bc = get_barycentric_coordinates(p3, t)
    @test is_inside(bc)

    p4 = Point([1.8, -2.1])
    @test !is_inside(p4, t)
    bc = get_barycentric_coordinates(p4, t)
    @test !is_inside(bc)
end

@testset "Refinement criteria" begin
    t = Triangle([[0, 0] [1, 0] [0, 1]], [1, 2, 3])
    tol = 0.1

    p1 = Point([0.1, 0.1], 5)
    @test refinement_criteria(p1, t, tol)

    p1 = Point([0, 0], 1.09)
    @test !refinement_criteria(p1, t, tol)

end

@testset "Distribute points" begin

    h = reshape(collect(1:6*5), 6, 5)
    m = TerrainMap(0, 0, 10, 10, h)
    idx = CartesianIndices(h)
    
    t1 = Triangle([[15, 15] [45, 0] [20, 40]], [1, 2, 3])
    map_t1 = view(idx, findall(look_for_points_inside_triangle(m, t1), idx))

    @test all(map_t1 == [CartesianIndex(4, 2), CartesianIndex(3, 3), CartesianIndex(4, 3), CartesianIndex(3, 4), CartesianIndex(3, 5)])

    # Now we are splitting the triangle
    t2 = Triangle([[15, 15] [35, 15] [20, 40]], [1, 2, 3])
    map_t2 = view(map_t1, findall(look_for_points_inside_triangle(m, t2), map_t1))

    @test all(map_t2 == [CartesianIndex(3, 3), CartesianIndex(4, 3), CartesianIndex(3, 4), CartesianIndex(3, 5)])

    t3 = Triangle([[15, 15] [45, 0] [35, 15]], [1, 2, 3])
    map_t3 = view(map_t1, findall(look_for_points_inside_triangle(m, t3), map_t1))

    @test all(map_t3 == [CartesianIndex(4, 2)])

end

@testset "Distribute and mark for refinement" begin

    tol = 0.1

    h = reshape(collect(1:6*5), 6, 5)
    m = TerrainMap(0, 0, 10, 10, h)
    idx = CartesianIndices(h)

    t1 = Triangle([[15, 15] [45, 0] [20, 40]], [1, 2, 3])
    (refine_t1, map_t1) = distribute_and_mark_for_refinement(m, idx, t1, tol)
    @test refine_t1
    @test all(map_t1 == [CartesianIndex(4, 2), CartesianIndex(3, 3), CartesianIndex(4, 3), CartesianIndex(3, 4), CartesianIndex(3, 5)])


    # Now we are splitting t1 into t2 and t3
    t2 = Triangle([[15, 15] [35, 15] [20, 40]], [1, 2, 3])
    (refine_t2, map_t2) = distribute_and_mark_for_refinement(m, map_t1, t2, tol)
    @test refine_t2
    @test all(map_t2 == [CartesianIndex(3, 3), CartesianIndex(4, 3), CartesianIndex(3, 4), CartesianIndex(3, 5)])

    t3 = Triangle([[15, 15] [45, 0] [35, 15]], [1, 2, 3])
    (refine_t3, map_t3) = distribute_and_mark_for_refinement(m, map_t1, t3, tol)
    @test refine_t3
    @test all(map_t3 == [CartesianIndex(4, 2)])

    # Now we are splitting t2 into t4 and t5
    t4 = Triangle([[15, 15] [25, 15] [20, 40]], [1, 2, 3])
    (refine_t4, map_t4) = distribute_and_mark_for_refinement(m, map_t2, t4, tol)
    @test refine_t4
    @test all(map_t4 == [CartesianIndex(3, 3), CartesianIndex(3, 4), CartesianIndex(3, 5)])

    t5 = Triangle([[25, 15] [35, 15] [20, 40]], [1, 2, 3])
    (refine_t5, map_t5) = distribute_and_mark_for_refinement(m, map_t2, t5, tol)
    @test refine_t5
    @test all(map_t5 == [CartesianIndex(4, 3), CartesianIndex(3, 5)])
end
