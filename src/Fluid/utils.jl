function calc_fluid_state(h, p, fluid_model)
    HP_inputs = get_input_pair_index("HmassP_INPUTS")
    AbstractState_update(Int32(fluid_model), HP_inputs, Real(h), Real(p))
    return fluid_model
end

function calc_fluid_property(property::String, fluid_state)
    property_index = get_param_index(property)
    return AbstractState_keyed_output(Int32(fluid_state), property_index)
end

@register_symbolic calc_fluid_state(h::Real, p::Real, fluid_model::Int32)
@register_symbolic calc_fluid_property(property::String, fluid_state::Int32)

@connector FluidPort begin
    @parameters begin
        fluid_model
    end

    @variables begin
        h(t), [guess=0.0]
        p(t), [guess=0.0]
        ṁ(t), [guess=0.0, connect = Flow]
    end
end

@connector FluidProperties begin
    @parameters begin
        fluid_model
    end

    @variables begin
        ṁ(t), [guess=0.0, connect = Flow]
    end

    @equations begin
        ṁ ~ 0
    end
end

@mtkmodel ResistanceSISO begin
    @components begin
        port_a = FluidPort()
        port_b = FluidPort()
    end

    @variables begin
        dp(t)
    end

    @equations begin
        # Conservation of mass
        0 ~ port_a.ṁ + port_b.ṁ

        # Conservation of energy
        0 ~ port_b.h - port_a.h

        # Conservation of momentum
        dp ~ port_b.p - port_a.p
    end
end