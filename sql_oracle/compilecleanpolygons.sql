create or replace function cleanpolygons (
     p_geom             mdsys.sdo_geometry
) return mdsys.sdo_geometry 
as

    -- when life gives you collection lemons
    -- you paint that ish polygon gold
    -- mschell! 20240711

    outgeom             sdo_geometry;
    tempgeom            sdo_geometry;

begin

    if p_geom is null
    then

        return outgeom;

    end if;

    for i in 1 .. sdo_util.getnumelem(p_geom)
    loop

        tempgeom := sdo_util.extract(p_geom,i);

        if  tempgeom.sdo_gtype in (2003,2007)
        and outgeom is null
        then 
            --not sure if 2007 is possible
            outgeom := tempgeom;

        elsif tempgeom.sdo_gtype in (2003,2007)
        then

            outgeom := sdo_util.append(outgeom
                                      ,tempgeom); 

        end if;

    end loop;

    --if the input is all junk it is ok to return null
    --caller will delete where validate_geometry_with_context <> 'TRUE'
    --validate_geometry_with_context is null when shape is null

    return outgeom;

end;