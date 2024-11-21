class FormaDePago{
    var monto //en el caso de credito, es el monto maximo de la cuota
    method restarDinero(persona,monto1)

    method puedePagar(persona,monto1){
        return monto > monto1
    }
}

class Efectivo inherits FormaDePago{
    override method restarDinero(persona,monto1){
        persona.dinero(persona.dinero() - monto1)
    }


}

class Debito inherits FormaDePago{
    override method restarDinero(persona,monto1){
        persona.cuentaBancaria().restarDineroDebito(monto1)
    }
}
//var credito = new Credito(cantCuotas = 12)
class Credito inherits FormaDePago{
    const cantCuotas
    
    method calcularInteres(persona,monto1){
        return ((monto1/cantCuotas)*persona.cuentaBancaria().interes())+monto1/cantCuotas
    }

    override method restarDinero(persona,monto1){
        persona.cuentaBancaria().restarDineroCredito(self.calcularInteres(persona,monto1))
    }

    override method puedePagar(persona,monto1){
        return monto > self.calcularInteres(persona,monto1)
    }

}
//punto 5
class CreditoFijo inherits Credito{
    override method calcularInteres(persona,monto1){
        return (monto1/cantCuotas)*1000
    }
}
//var cuentabanc = new CuentaBancaria(saldo = 1000,montoMax = 1000,deudaCuota = 0,interes = 0.1)
class CuentaBancaria{
    var saldo

    var property deudaCuota = 0

    const interes // lo determina el BCRA
    method interes() = interes

    method restarDineroDebito(monto){
        saldo -= monto
    }

    method restarDineroCredito(monto){
            deudaCuota += monto
    }
}  
// var pers = new Persona(formasDePago = [credito],formaPreferida = credito,cuentaBancaria = cuentabanc,dinero = 1000) 
class Persona{
    var sueldo
    const formasDePago
    var formaPreferida
    const cuentaBancaria
    method cuentaBancaria() = cuentaBancaria
    var property dinero
    const items = []

    method realizarCompra(item,formaDePago){
        formaDePago.restarDinero(self, item.precio())
        items.add(item)
    }

    method comprar(item){
        if(formaPreferida.puedePagar(self,item.precio())){
            self.realizarCompra(item, formaPreferida)
        }
    }

    method cambiarFormaPreferida(formaDePago){
        if(formasDePago.contains(formaDePago)){
            formaPreferida = formaDePago
        }else{
            self.error("no tiene esa forma de pago")
        }
    }

    method pagarDeuda(monto){
        if(cuentaBancaria.deudaCuota() > monto){
            cuentaBancaria.deudaCuota(cuentaBancaria.deudaCuota() - monto)
            return 0
        }else{
            var monto1
            monto1 = monto - cuentaBancaria.deudaCuota()
            cuentaBancaria.deudaCuota(0)
            return monto1
        }
    }

    method cobrarSalario(){
        const sobrante = self.pagarDeuda(sueldo)
        dinero = dinero + sobrante
    }

    method cambiarSueldo(sueldo1){
        if(sueldo1 < sueldo){
            self.error("No puede disminuir el sueldo")
        }
        sueldo = sueldo1
    }

    method transcurrirMes(){
        self.cobrarSalario()
    }

    method montoTotalDeuda(){
        return cuentaBancaria.deudaCuota()
    }
}


class Item{
    const precio
    method precio() = precio
}



class CompradorCompulsivo inherits Persona{
    override method comprar(item){
        if(formaPreferida.puedePagar(self,item.precio())){
            super(item)
        }else{
            const formasPosibles = formasDePago.filter({forma => forma.puedePagar(self,item.precio()) && forma != formaPreferida})
            if(formasPosibles != []){
                self.realizarCompra(item, formasPosibles.anyOne())
            }
        }
    }
}

class PagadorCompulsivo inherits Persona{
    override method pagarDeuda(monto){
        const monto1 = super(monto)
        if(monto1 == 0 && dinero > cuentaBancaria.deudaCuota()){
            dinero = dinero - monto1
            cuentaBancaria.deudaCuota(0)
        }
    }
}